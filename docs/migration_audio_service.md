# audio_service

**Alt → Neu:** `audio_service: ^0.18.7` → `audio_service: ^0.18.17`

## Zweck der Migration

Aktualisierung für Android 14+ Foreground-Service-Anforderungen (`foregroundServiceType="mediaPlayback"`) und Dart-3-Kompatibilität.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 40 | `audio_service: ^0.18.7` | `audio_service: ^0.18.17` | Dart 3 / Flutter 3.44 compatibility version bump |
| `android/app/src/main/AndroidManifest.xml` | 13 | *(nicht vorhanden)* | `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Berechtigung für Media-Playback-Foreground-Service (Android 14+) |
| `android/app/src/main/AndroidManifest.xml` | 62–64 | `<service … AudioService …>` (ohne Typ) | `android:foregroundServiceType="mediaPlayback"` | Foreground-Service-Typ für Hintergrund-Audio |

## Integration Test

`integration_test/packages/migration_audio_service_test.dart`
