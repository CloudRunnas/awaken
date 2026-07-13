#!/usr/bin/env bash
# Run package integration tests on a local Android emulator.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/local_test_env.sh"

AVD_NAME="${AVD_NAME:-phoenix_test}"
EMULATOR_PID=""

cleanup() {
  if [[ -n "$EMULATOR_PID" ]] && kill -0 "$EMULATOR_PID" 2>/dev/null; then
    echo "Stopping emulator (pid $EMULATOR_PID)..."
    kill "$EMULATOR_PID" 2>/dev/null || true
    adb -s emulator-5554 emu kill 2>/dev/null || true
  fi
}
trap cleanup EXIT

cd "$REPO_ROOT"

mkdir -p android
if ! grep -q "sdk.dir" android/local.properties 2>/dev/null; then
  {
    echo "flutter.sdk=$HOME/flutter"
    echo "sdk.dir=$ANDROID_HOME"
  } > android/local.properties
fi

"$SCRIPT_DIR/setup_android_emulator.sh"

flutter pub get
bash scripts/patch_android_namespaces.sh
bash scripts/patch_on_audio_edit_kotlin.sh
bash scripts/patch_legacy_compile_sdk.sh

if ! adb devices | grep -q "emulator-5554[[:space:]]*device"; then
  echo "Starting emulator '${AVD_NAME}'..."
  emulator -avd "$AVD_NAME" -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect &
  EMULATOR_PID=$!
  adb wait-for-device
  until [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
    sleep 2
  done
  echo "Emulator boot complete."
else
  echo "Emulator already running."
fi

flutter test integration_test/packages/
