# flutter_displaymode

**Alt → Neu:** `flutter_displaymode: ^0.4.0` → `flutter_displaymode: ^0.6.0`

## Zweck der Migration

Dart 3 / Flutter 3.44 compatibility version bump.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 54 | `flutter_displaymode: ^0.4.0` | `flutter_displaymode: ^0.6.0` | Dart 3 / Flutter 3.44 compatibility version bump |
| `android/build.gradle.kts` | subprojects | — | `compileSdk = 34` wenn Plugin < 34 | AGP 9: AndroidX lifecycle verlangt compileSdk ≥ 34 |
| `scripts/patch_legacy_compile_sdk.sh` | neu | — | `compileSdkVersion` 30/33 → `34` für on_audio_edit, on_audio_query_android, flutter_displaymode | Plugin build.gradle überschreibt Gradle-KTS-Override |
| `android/app/build.gradle.kts` | release | — | `isMinifyEnabled = false` | R8: fehlende Play-Core-Klasse bei Flutter 3.44 |

## Integration Test

`integration_test/packages/migration_flutter_displaymode_test.dart`
