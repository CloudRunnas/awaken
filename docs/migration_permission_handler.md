# permission_handler

**Alt → Neu:** `permission_handler: ^10.0.0` → `permission_handler: ^11.4.0`

## Zweck der Migration

Android 13+ (API 33) erfordert `READ_MEDIA_AUDIO` statt `READ_EXTERNAL_STORAGE` für Musikbibliothek-Zugriff. Zentralisierte Hilfsfunktion `requestMusicLibraryPermission()` wählt die richtige Permission basierend auf SDK-Version.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 51 | `permission_handler: ^10.0.0` | `permission_handler: ^11.4.0` | Dart 3 / Flutter 3.44 compatibility version bump |
| `android/app/src/main/AndroidManifest.xml` | 6 | `READ_EXTERNAL_STORAGE` (ohne maxSdk) | `android:maxSdkVersion="32"` | Legacy-Storage-Permission nur bis API 32 |
| `android/app/src/main/AndroidManifest.xml` | 7–9 | `WRITE_EXTERNAL_STORAGE` (ohne maxSdk) | `android:maxSdkVersion="32"` | Legacy-Schreibzugriff nur bis API 32 |
| `android/app/src/main/AndroidManifest.xml` | 10 | *(nicht vorhanden)* | `READ_MEDIA_AUDIO` | Android 13+ Audio-Medienzugriff |
| `lib/src/beginning/utilities/init.dart` | 52–60 | *(nicht vorhanden)* | `Future<bool> requestMusicLibraryPermission() { … Permission.audio / Permission.storage … }` | SDK-abhängige Medienberechtigung |
| `lib/src/beginning/utilities/init.dart` | 63 | `Permission.storage.request().isGranted` | `requestMusicLibraryPermission()` | Song-Scan mit korrekter Permission |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | 26 | *(nicht vorhanden)* | `import 'package:phoenix/src/beginning/utilities/init.dart';` | Zugriff auf `requestMusicLibraryPermission()` |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | 403–404 | `Permission.storage.request().isGranted` | `requestMusicLibraryPermission()` | Datei-Löschen mit korrekter Permission |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | 872–873 | `Permission.storage.request().isGranted` | `requestMusicLibraryPermission()` | Wallpaper-Speichern mit korrekter Permission |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | 938–939 | `Permission.storage.request().isGranted` | `requestMusicLibraryPermission()` | Datei-Löschen (Extended) mit korrekter Permission |

## Integration Test

`integration_test/packages/migration_permission_handler_test.dart`
