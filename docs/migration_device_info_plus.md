# device_info_plus

**Alt → Neu:** `device_info: ^2.0.3` → `device_info_plus: ^11.3.0`

## Zweck der Migration

`device_info` ist veraltet und nicht Dart-3-kompatibel. `device_info_plus` ist der offizielle Nachfolger mit gleicher `DeviceInfoPlugin`-API und wird für Android-SDK-Erkennung (API 33+ Medienberechtigungen) genutzt.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 48 | `device_info: ^2.0.3` | `device_info_plus: ^11.3.0` | Paket-Ersatz für Dart 3 / Flutter 3.44 |
| `lib/src/beginning/utilities/init.dart` | 4 | `import 'package:device_info/device_info.dart';` | `import 'package:device_info_plus/device_info_plus.dart';` | Import auf Nachfolger-Paket umstellen |
| `lib/src/beginning/utilities/init.dart` | 42–43 | `DeviceInfoPlugin().androidInfo` | `DeviceInfoPlugin().androidInfo` | SDK-Int-Abfrage für `isAndroid11` (API unverändert) |
| `lib/src/beginning/utilities/init.dart` | 54 | *(in neuer Funktion)* | `(await DeviceInfoPlugin().androidInfo).version.sdkInt` | SDK-Version für Medienberechtigungs-Logik (API ≥ 33) |

## Integration Test

`integration_test/packages/migration_device_info_plus_test.dart`
