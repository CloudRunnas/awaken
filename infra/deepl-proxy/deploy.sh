#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

AWS_REGION="${AWS_REGION:-eu-central-1}"
FUNCTION_NAME="${FUNCTION_NAME:-phoenix-deepl-proxy}"
RUNTIME="${RUNTIME:-python3.13}"
HANDLER="${HANDLER:-handler.lambda_handler}"
ROLE_NAME="${ROLE_NAME:-phoenix-deepl-proxy-role}"
TABLE_NAME="${TABLE_NAME:-phoenix-translation-usage}"
DAILY_LIMIT="${DAILY_LIMIT:-2000}"
DEEPL_API_URL="${DEEPL_API_URL:-https://api-free.deepl.com}"

: "${DEEPL_API_KEY:?DEEPL_API_KEY is required}"
: "${PHOENIX_TRANSLATION_API_KEY:?PHOENIX_TRANSLATION_API_KEY is required}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

echo "Ensuring DynamoDB table ${TABLE_NAME}..."
if ! aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
  aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions \
      AttributeName=apiKey,AttributeType=S \
      AttributeName=date,AttributeType=S \
    --key-schema \
      AttributeName=apiKey,KeyType=HASH \
      AttributeName=date,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --region "$AWS_REGION"
  aws dynamodb wait table-exists --table-name "$TABLE_NAME" --region "$AWS_REGION"
fi

aws dynamodb update-time-to-live \
  --table-name "$TABLE_NAME" \
  --time-to-live-specification "Enabled=true,AttributeName=expiresAt" \
  --region "$AWS_REGION" >/dev/null 2>&1 || true

echo "Ensuring IAM role ${ROLE_NAME}..."
TRUST_POLICY='{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "lambda.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}'

if ! aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document "$TRUST_POLICY" >/dev/null
fi

DDB_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["dynamodb:UpdateItem", "dynamodb:GetItem", "dynamodb:PutItem"],
    "Resource": "arn:aws:dynamodb:${AWS_REGION}:${ACCOUNT_ID}:table/${TABLE_NAME}"
  }]
}
EOF
)

aws iam put-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "${ROLE_NAME}-ddb" \
  --policy-document "$DDB_POLICY" >/dev/null

aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole >/dev/null 2>&1 || true

echo "Waiting for IAM role propagation..."
sleep 10

ZIP_FILE="${ROOT_DIR}/function.zip"
rm -f "$ZIP_FILE"
zip -j "$ZIP_FILE" handler.py >/dev/null

ENV_VARS="DEEPL_API_KEY=${DEEPL_API_KEY},PHOENIX_APP_API_KEY=${PHOENIX_TRANSLATION_API_KEY},DEEPL_API_URL=${DEEPL_API_URL},DAILY_LIMIT=${DAILY_LIMIT},DYNAMODB_TABLE=${TABLE_NAME}"

if aws lambda get-function --function-name "$FUNCTION_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
  echo "Updating Lambda ${FUNCTION_NAME}..."
  aws lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file "fileb://${ZIP_FILE}" \
    --region "$AWS_REGION" >/dev/null
  aws lambda wait function-updated --function-name "$FUNCTION_NAME" --region "$AWS_REGION"
  aws lambda update-function-configuration \
    --function-name "$FUNCTION_NAME" \
    --runtime "$RUNTIME" \
    --handler "$HANDLER" \
    --timeout 15 \
    --memory-size 256 \
    --environment "Variables={${ENV_VARS}}" \
    --region "$AWS_REGION" >/dev/null
  aws lambda wait function-updated --function-name "$FUNCTION_NAME" --region "$AWS_REGION"
else
  echo "Creating Lambda ${FUNCTION_NAME}..."
  aws lambda create-function \
    --function-name "$FUNCTION_NAME" \
    --runtime "$RUNTIME" \
    --role "$ROLE_ARN" \
    --handler "$HANDLER" \
    --zip-file "fileb://${ZIP_FILE}" \
    --timeout 15 \
    --memory-size 256 \
    --environment "Variables={${ENV_VARS}}" \
    --region "$AWS_REGION" >/dev/null
  aws lambda wait function-active --function-name "$FUNCTION_NAME" --region "$AWS_REGION"
fi

echo "Ensuring Function URL..."
FUNCTION_URL="$(aws lambda get-function-url-config \
  --function-name "$FUNCTION_NAME" \
  --region "$AWS_REGION" \
  --query FunctionUrl \
  --output text 2>/dev/null || true)"

if [[ -z "$FUNCTION_URL" || "$FUNCTION_URL" == "None" ]]; then
  FUNCTION_URL="$(aws lambda create-function-url-config \
    --function-name "$FUNCTION_NAME" \
    --auth-type NONE \
    --cors "AllowOrigins=*,AllowMethods=POST,AllowHeaders=content-type,x-phoenix-api-key" \
    --region "$AWS_REGION" \
    --query FunctionUrl \
    --output text)"
fi

aws lambda add-permission \
  --function-name "$FUNCTION_NAME" \
  --statement-id FunctionURLAllowPublicAccess \
  --action lambda:InvokeFunctionUrl \
  --principal "*" \
  --function-url-auth-type NONE \
  --region "$AWS_REGION" >/dev/null 2>&1 || true

echo "$FUNCTION_URL" > "${ROOT_DIR}/.function_url"
echo "Deployed: ${FUNCTION_URL}"
