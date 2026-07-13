#!/usr/bin/env bash
# Patches on_audio_edit Kotlin sources for Kotlin 2.x / AGP 9 compatibility.
set -euo pipefail

patch_warning_size() {
  local file="$1"
  cat > "$file" <<'EOF'
package com.lucasjosino.on_audio_edit.utils

import android.util.Log

fun warningSizeCall(sizeValue: Long, data: String) {
    when {
        sizeValue >= 13 -> {
            Log.e("on_audio_warning","-------------------------------------------------------------------------------------")
            Log.e("on_audio_wn_size", "[$data] size is bigger than 13 MB - [$sizeValue MB]")
            Log.e("on_audio_warning","-------------------------------------------------------------------------------------")
        }
        sizeValue >= 10 -> {
            Log.e("on_audio_warning", "[$data] size is bigger than 10 MB - [$sizeValue MB]")
        }
        sizeValue >= 6 -> {
            Log.i("on_audio_warning", "[$data] size is bigger than 6 MB - [$sizeValue MB]")
        }
        else -> {}
    }
}
EOF
  echo "Rewrote OnWarningSizeCall in $file"
}

patch_puri() {
  local file="$1"
  sed -i 's/val pUri: Uri/var pUri: Uri/' "$file"
  echo "Patched pUri declaration in $file"
}

find "${PUB_CACHE:-$HOME/.pub-cache}" -path "*/on_audio_edit-*/android/src/main/kotlin/**/OnWarningSizeCall.kt" 2>/dev/null | while read -r file; do
  patch_warning_size "$file"
done

for name in OnAudioEdit10.kt OnArtworkEdit10.kt; do
  find "${PUB_CACHE:-$HOME/.pub-cache}" -path "*/on_audio_edit-*/android/src/main/kotlin/**/$name" 2>/dev/null | while read -r file; do
    patch_puri "$file"
  done
done
