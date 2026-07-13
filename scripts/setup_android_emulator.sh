#!/usr/bin/env bash
# Creates the local Android emulator used for integration tests (once).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/local_test_env.sh"

AVD_NAME="${AVD_NAME:-phoenix_test}"

if avdmanager list avd | grep -q "Name: ${AVD_NAME}"; then
  echo "AVD '${AVD_NAME}' already exists."
  exit 0
fi

if ! sdkmanager --list_installed 2>/dev/null | grep -q "system-images;android-34;google_apis;x86_64"; then
  echo "Installing emulator system image (API 34)..."
  yes | sdkmanager "emulator" "system-images;android-34;google_apis;x86_64"
fi

echo "Creating AVD '${AVD_NAME}'..."
echo no | avdmanager create avd \
  -n "$AVD_NAME" \
  -k "system-images;android-34;google_apis;x86_64" \
  -d "pixel_6"

AVD_DIR="$HOME/.android/avd/${AVD_NAME}.avd"
if [[ -f "$AVD_DIR/config.ini" ]]; then
  # Smaller RAM + no snapshots = faster cold boots on hosts without KVM.
  sed -i 's/^hw.ramSize=.*/hw.ramSize=1536/' "$AVD_DIR/config.ini" 2>/dev/null || true
  grep -q '^hw.ramSize=' "$AVD_DIR/config.ini" || echo 'hw.ramSize=1536' >> "$AVD_DIR/config.ini"
  sed -i 's/^snapshot.present=.*/snapshot.present=no/' "$AVD_DIR/config.ini" 2>/dev/null || true
  grep -q '^snapshot.present=' "$AVD_DIR/config.ini" || echo 'snapshot.present=no' >> "$AVD_DIR/config.ini"
fi

echo "AVD '${AVD_NAME}' ready."
