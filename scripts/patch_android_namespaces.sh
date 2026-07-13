#!/usr/bin/env bash
# Patches legacy Flutter plugins in pub-cache that lack android.namespace (AGP 8+).
set -euo pipefail

patch_plugin() {
  local pattern="$1"
  local namespace="$2"
  find "${PUB_CACHE:-$HOME/.pub-cache}" -path "*/${pattern}/android/build.gradle" 2>/dev/null | while read -r file; do
    if ! grep -q 'namespace' "$file"; then
      sed -i "/android\s*{/a\\    namespace '${namespace}'" "$file"
      echo "Patched namespace in $file"
    fi
  done
}

patch_plugin "on_audio_edit-*" "com.lucasjosino.on_audio_edit"
patch_plugin "on_audio_query_android-*" "com.lucasjosino.on_audio_query"
patch_plugin "on_audio_query-*" "com.lucasjosino.on_audio_query"
patch_plugin "flare_flutter-*" "com.example.flare_flutter"
