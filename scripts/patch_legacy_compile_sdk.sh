#!/usr/bin/env bash
# Patches legacy Flutter plugins that pin compileSdk < 34 in their build.gradle.
# Gradle subproject overrides in build.gradle.kts are ignored when plugins set compileSdkVersion directly.
set -euo pipefail

patch_compile_sdk() {
  local pattern="$1"
  find "${PUB_CACHE:-$HOME/.pub-cache}" -path "*/${pattern}/android/build.gradle" 2>/dev/null | while read -r file; do
    if grep -qE 'compileSdkVersion (30|31|32|33)' "$file"; then
      sed -i -E 's/compileSdkVersion (30|31|32|33)/compileSdkVersion 34/' "$file"
      echo "Patched compileSdk in $file"
    fi
  done
}

patch_compile_sdk "on_audio_edit-*"
patch_compile_sdk "on_audio_query_android-*"
patch_compile_sdk "flutter_displaymode-*"
