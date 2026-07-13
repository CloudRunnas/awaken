#!/usr/bin/env bash
# Patches flutter_displaymode for compileSdk 34+ (AndroidX lifecycle 2.7).
set -euo pipefail

find "${PUB_CACHE:-$HOME/.pub-cache}" -path "*/flutter_displaymode-*/android/build.gradle" 2>/dev/null | while read -r file; do
  if grep -q 'compileSdkVersion 33' "$file"; then
    sed -i 's/compileSdkVersion 33/compileSdkVersion 34/' "$file"
    echo "Patched compileSdk in $file"
  fi
done
