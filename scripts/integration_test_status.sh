#!/usr/bin/env bash
# Show progress of the latest local integration test run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="${LOG_FILE:-$REPO_ROOT/integration_test_run.log}"

echo "=== Process ==="
pgrep -af "run_integration_tests|flutter test integration_test|emulator -avd" 2>/dev/null || echo "(none running)"

echo
echo "=== adb devices ==="
# shellcheck source=/dev/null
source "$SCRIPT_DIR/local_test_env.sh"
adb devices 2>/dev/null || echo "adb unavailable"

echo
echo "=== Log tail (${LOG_FILE}) ==="
if [[ -f "$LOG_FILE" ]]; then
  tail -25 "$LOG_FILE"
  echo
  if rg -q "All integration tests passed" "$LOG_FILE" 2>/dev/null; then
    echo "STATUS: PASSED"
  elif rg -q "Integration tests failed" "$LOG_FILE" 2>/dev/null; then
    echo "STATUS: FAILED"
  elif pgrep -f "run_integration_tests.sh" >/dev/null 2>&1; then
    echo "STATUS: RUNNING"
  else
    echo "STATUS: UNKNOWN (see log)"
  fi
else
  echo "(no log yet — run: bash scripts/run_integration_tests.sh)"
fi
