# on_audio_query

**Alt → Neu:** `on_audio_query: '2.6.1'` → `on_audio_query: ^2.9.0`

## Zweck der Migration

Aktualisierung für Android 13+ Medienberechtigungen und Dart-3-Kompatibilität. Song-Abfrage nutzt jetzt `requestMusicLibraryPermission()` vor `OnAudioQuery().querySongs()`.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 44 | `on_audio_query: '2.6.1'` | `on_audio_query: ^2.9.0` | Dart 3 / Flutter 3.44 compatibility version bump |
| `lib/src/beginning/utilities/init.dart` | 63 | `if (await Permission.storage.request().isGranted)` | `if (await requestMusicLibraryPermission())` | Korrekte Medienberechtigung vor Song-Query (API 33+) |
| `scripts/patch_legacy_compile_sdk.sh` | neu | — | `on_audio_query_android` compileSdk 33 → 34 | AGP 9: Plugin build.gradle überschreibt Gradle-KTS-Override |

## Integration Test

`integration_test/packages/migration_on_audio_query_test.dart`
