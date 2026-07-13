# screenshot

**Alt → Neu:** `screenshot: ^1.2.3` → `screenshot: ^3.0.0`

## Zweck der Migration

Dart 3 / Flutter 3.44 compatibility version bump. Import-Pfade auf lokale Screenshot-Hilfsdatei korrigiert (Groß-/Kleinschreibung für case-sensitive Dateisysteme unter Linux).

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 80 | `screenshot: ^1.2.3` | `screenshot: ^3.0.0` | Dart 3 / Flutter 3.44 compatibility version bump |
| `lib/src/beginning/utilities/audio_handlers/previous_play_skip.dart` | 11 | `import '…/screenshot_ui.dart';` | `import '…/screenshot_UI.dart';` | Korrekte Dateiname-Schreibweise (Linux case-sensitive) |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | 24 | `import '…/screenshot_ui.dart';` | `import '…/screenshot_UI.dart';` | Korrekte Dateiname-Schreibweise (Linux case-sensitive) |

## Integration Test

`integration_test/packages/migration_screenshot_test.dart`
