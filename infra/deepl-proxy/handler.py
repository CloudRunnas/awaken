"""AWS Lambda proxy: app API-key auth, daily rate limit, DeepL forward."""

from __future__ import annotations

import json
import os
import urllib.error
import urllib.request
from datetime import datetime, timedelta, timezone

import boto3
from botocore.exceptions import ClientError

DEEPL_API_KEY = os.environ.get("DEEPL_API_KEY", "")
PHOENIX_APP_API_KEY = os.environ.get("PHOENIX_APP_API_KEY", "")
DEEPL_API_URL = os.environ.get("DEEPL_API_URL", "https://api-free.deepl.com")
DAILY_LIMIT = int(os.environ.get("DAILY_LIMIT", "2000"))
TABLE_NAME = os.environ.get("DYNAMODB_TABLE", "phoenix-translation-usage")

_dynamodb = boto3.resource("dynamodb")
_table = _dynamodb.Table(TABLE_NAME)


def _cors_headers() -> dict[str, str]:
    return {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type,X-Phoenix-Api-Key",
        "Access-Control-Allow-Methods": "POST,OPTIONS",
        "Content-Type": "application/json",
    }


def _response(status: int, body: dict | list) -> dict:
    return {
        "statusCode": status,
        "headers": _cors_headers(),
        "body": json.dumps(body),
    }


def _consume_rate_limit(api_key: str) -> bool:
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    expires_at = int((datetime.now(timezone.utc) + timedelta(days=2)).timestamp())
    try:
        _table.update_item(
            Key={"apiKey": api_key, "date": today},
            UpdateExpression="SET #count = if_not_exists(#count, :zero) + :inc, expiresAt = :exp",
            ConditionExpression="attribute_not_exists(#count) OR #count < :limit",
            ExpressionAttributeNames={"#count": "count"},
            ExpressionAttributeValues={
                ":zero": 0,
                ":inc": 1,
                ":limit": DAILY_LIMIT,
                ":exp": expires_at,
            },
        )
        return True
    except ClientError as exc:
        if exc.response["Error"]["Code"] == "ConditionalCheckFailedException":
            return False
        raise


def _translate_with_deepl(payload: dict) -> tuple[int, dict]:
    url = f"{DEEPL_API_URL.rstrip('/')}/v2/translate"
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"DeepL-Auth-Key {DEEPL_API_KEY}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            return response.status, json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        try:
            parsed = json.loads(detail)
        except json.JSONDecodeError:
            parsed = {"message": detail}
        return exc.code, {"error": "deepl_error", "detail": parsed}


def lambda_handler(event, context):  # noqa: ARG001
    method = event.get("requestContext", {}).get("http", {}).get("method", "POST")
    if method == "OPTIONS":
        return {"statusCode": 204, "headers": _cors_headers(), "body": ""}

    raw_headers = event.get("headers") or {}
    headers = {str(k).lower(): v for k, v in raw_headers.items()}
    api_key = headers.get("x-phoenix-api-key", "")

    if not PHOENIX_APP_API_KEY or api_key != PHOENIX_APP_API_KEY:
        return _response(401, {"error": "unauthorized"})

    if not _consume_rate_limit(api_key):
        return _response(429, {"error": "rate_limit_exceeded", "limit": DAILY_LIMIT})

    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _response(400, {"error": "invalid_json"})

    text = (body.get("text") or "").strip()
    target_lang = (body.get("target_lang") or "").strip()
    if not text or not target_lang:
        return _response(400, {"error": "missing_text_or_target_lang"})

    deepl_payload: dict = {"text": [text], "target_lang": target_lang}
    source_lang = (body.get("source_lang") or "").strip()
    if source_lang:
        deepl_payload["source_lang"] = source_lang

    status, result = _translate_with_deepl(deepl_payload)
    if status >= 400:
        return _response(status if status < 500 else 502, result)
    return _response(200, result)
