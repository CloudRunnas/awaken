# Dart / Flutter SDK Migration

**Alt → Neu:** `sdk: '>=2.12.0 <3.0.0'` → `sdk: '>=3.5.0 <4.0.0'`

## Zweck der Migration

Upgrade auf Dart 3 und Flutter 3.44: Null-Safety-Anforderungen, entfernte APIs (`Paint.enableDithering`, `WillPopScope`, `MaterialStateProperty`) und Material-3-Standardverhalten absichern.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 20 | `sdk: '>=2.12.0 <3.0.0'` | `sdk: '>=3.5.0 <4.0.0'` | Dart-3-SDK-Constraint für Flutter 3.44 |
| `lib/main.dart` | 29 | `Paint.enableDithering = true;` | *(entfernt)* | API in Flutter 3 entfernt; Dithering ist Standard |
| `lib/src/beginning/utilities/constants.dart` | 61 | *(nicht gesetzt)* | `useMaterial3: false,` | Material 3 deaktivieren, bestehendes Material-2-Design beibehalten |
| `lib/src/beginning/utilities/constants.dart` | 73 | `MaterialStateProperty.all(false)` | `WidgetStateProperty.all(false)` | `MaterialStateProperty` → `WidgetStateProperty` (Flutter 3) |
| `lib/src/beginning/utilities/constants.dart` | 75 | `MaterialStateProperty.all(4)` | `WidgetStateProperty.all(4)` | `MaterialStateProperty` → `WidgetStateProperty` (Flutter 3) |
| `lib/src/beginning/utilities/constants.dart` | 77 | `MaterialStateProperty.all(Colors.white30)` | `WidgetStateProperty.all(Colors.white30)` | `MaterialStateProperty` → `WidgetStateProperty` (Flutter 3) |
| `lib/src/beginning/begin.dart` | 5 | *(nicht vorhanden)* | `import 'package:flutter/services.dart';` | `SystemNavigator.pop()` für PopScope-Rücknavigation |
| `lib/src/beginning/begin.dart` | 129–136 | `WillPopScope(onWillPop: _onWillPop, …)` | `PopScope(canPop: false, onPopInvokedWithResult: …)` | `WillPopScope` deprecated → `PopScope` (Flutter 3) |
| `lib/src/beginning/pages/settings/settings_pages/directories.dart` | 166–171 | `WillPopScope(onWillPop: _onWillPop, …)` | `PopScope(canPop: false, onPopInvokedWithResult: …)` | `WillPopScope` deprecated → `PopScope` (Flutter 3) |

## Integration Test

Kein dedizierter SDK-Integrations-Test. SDK-Änderungen werden indirekt durch alle Paket-Integrations-Tests abgedeckt.
