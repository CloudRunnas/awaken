#!/usr/bin/env bash
# Run package integration tests on a local Android emulator or connected device.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/local_test_env.sh"

AVD_NAME="${AVD_NAME:-phoenix_test}"
LOG_FILE="${LOG_FILE:-$REPO_ROOT/integration_test_run.log}"
KEEP_EMULATOR="${KEEP_EMULATOR:-0}"
ADB_CONNECT_TIMEOUT_SEC="${ADB_CONNECT_TIMEOUT_SEC:-900}"
BOOT_TIMEOUT_SEC="${BOOT_TIMEOUT_SEC:-900}"
EMULATOR_PID=""
STARTED_EMULATOR=0

log() {
  echo "[$(date -u +%H:%M:%S)] $*" | tee -a "$LOG_FILE"
}

cleanup() {
  if [[ "$KEEP_EMULATOR" == "1" ]]; then
    log "KEEP_EMULATOR=1 — emulator left running."
    return
  fi
  if [[ "$STARTED_EMULATOR" == "1" ]] && [[ -n "$EMULATOR_PID" ]] && kill -0 "$EMULATOR_PID" 2>/dev/null; then
    log "Stopping emulator (pid $EMULATOR_PID)..."
    kill "$EMULATOR_PID" 2>/dev/null || true
    adb -s emulator-5554 emu kill 2>/dev/null || true
  fi
}
trap cleanup EXIT

has_kvm() {
  [[ -r /dev/kvm ]] && [[ -w /dev/kvm ]]
}

wait_for_adb_device() {
  local serial="$1"
  local deadline=$((SECONDS + ADB_CONNECT_TIMEOUT_SEC))
  while (( SECONDS < deadline )); do
    if adb devices | awk 'NR>1 && $2=="device" {print $1}' | grep -qx "$serial"; then
      return 0
    fi
    if [[ -n "$EMULATOR_PID" ]] && ! kill -0 "$EMULATOR_PID" 2>/dev/null; then
      log "Emulator process exited before adb connected."
      return 1
    fi
    sleep 3
  done
  return 1
}

wait_for_boot_completed() {
  local serial="$1"
  local deadline=$((SECONDS + BOOT_TIMEOUT_SEC))
  while (( SECONDS < deadline )); do
    local boot
    boot="$(adb -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
    if [[ "$boot" == "1" ]]; then
      return 0
    fi
    sleep 5
  done
  return 1
}

pick_device_serial() {
  # Prefer a physical device if one is connected.
  adb devices | awk 'NR>1 && $2=="device" && $1 !~ /^emulator-/ {print $1; exit}'
}

cd "$REPO_ROOT"
: > "$LOG_FILE"

mkdir -p android
{
  echo "flutter.sdk=$HOME/flutter"
  echo "sdk.dir=$ANDROID_HOME"
} > android/local.properties

log "=== Integration test run started ==="
log "Host KVM: $(has_kvm && echo yes || echo no)"

"$SCRIPT_DIR/setup_android_emulator.sh" | tee -a "$LOG_FILE"

log "flutter pub get"
flutter pub get 2>&1 | tee -a "$LOG_FILE"
bash scripts/patch_android_namespaces.sh 2>&1 | tee -a "$LOG_FILE"
bash scripts/patch_on_audio_edit_kotlin.sh 2>&1 | tee -a "$LOG_FILE"
bash scripts/patch_legacy_compile_sdk.sh 2>&1 | tee -a "$LOG_FILE"

DEVICE_SERIAL="${DEVICE_SERIAL:-$(pick_device_serial)}"

if [[ -z "$DEVICE_SERIAL" ]]; then
  EMULATOR_ARGS=(-avd "$AVD_NAME" -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect -no-snapshot-load -no-snapshot-save)
  if has_kvm; then
    log "Starting emulator '${AVD_NAME}' with hardware acceleration..."
  else
    log "Starting emulator '${AVD_NAME}' in software mode (-no-accel, no KVM)..."
    EMULATOR_ARGS+=(-no-accel)
  fi
  emulator "${EMULATOR_ARGS[@]}" >> "$LOG_FILE" 2>&1 &
  EMULATOR_PID=$!
  STARTED_EMULATOR=1
  DEVICE_SERIAL="emulator-5554"
  log "Waiting for adb device ${DEVICE_SERIAL} (timeout ${ADB_CONNECT_TIMEOUT_SEC}s)..."
  if ! wait_for_adb_device "$DEVICE_SERIAL"; then
    log "ERROR: Timed out waiting for emulator adb connection."
    exit 1
  fi
  log "Waiting for boot_completed (timeout ${BOOT_TIMEOUT_SEC}s)..."
  if ! wait_for_boot_completed "$DEVICE_SERIAL"; then
    log "ERROR: Timed out waiting for emulator boot."
    exit 1
  fi
  log "Emulator boot complete."
else
  log "Using connected device: ${DEVICE_SERIAL}"
fi

log "Running flutter test integration_test/packages/ on ${DEVICE_SERIAL}..."
set +e
flutter test integration_test/packages/ -d "$DEVICE_SERIAL" 2>&1 | tee -a "$LOG_FILE"
TEST_EXIT=${PIPESTATUS[0]}
set -e

if [[ "$TEST_EXIT" == "0" ]]; then
  log "=== All integration tests passed ==="
else
  log "=== Integration tests failed (exit ${TEST_EXIT}) ==="
fi
exit "$TEST_EXIT"
