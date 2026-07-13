# awesome_notifications

**Alt → Neu:** `awesome_notifications: ^0.6.21` → `awesome_notifications: ^0.10.1`

## Zweck der Migration

Dart 3 / Flutter 3.44 compatibility version bump. Android 13+ erfordert `POST_NOTIFICATIONS` im Manifest für Runtime-Benachrichtigungsberechtigung.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 79 | `awesome_notifications: ^0.6.21` | `awesome_notifications: ^0.10.1` | Dart 3 / Flutter 3.44 compatibility version bump |
| `android/app/src/main/AndroidManifest.xml` | 14 | *(nicht vorhanden)* | `POST_NOTIFICATIONS` | Android 13+ Benachrichtigungs-Runtime-Permission |

## Integration Test

`integration_test/packages/migration_awesome_notifications_test.dart`
