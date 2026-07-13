# ffmpeg_kit_flutter_new

**Alt → Neu:** `flutter_ffmpeg: ^0.4.2` → `ffmpeg_kit_flutter_new: ^2.0.0`

## Zweck der Migration

`flutter_ffmpeg` ist eingestellt und nicht mit modernem Android/Gradle kompatibel. `ffmpeg_kit_flutter_new` ist der aktiv gepflegte Nachfolger mit `FFmpegKit.execute()`-API für Klingelton-Trimming und Audio-Konvertierung.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 41 | `flutter_ffmpeg: ^0.4.2` | `ffmpeg_kit_flutter_new: ^2.0.0` | Paket-Ersatz für Dart 3 / Flutter 3.44 |
| `android/build.gradle` | 22–24 | `flutterFFmpegPackage = "min"` | *(entfernt)* | FFmpeg-Package-Konfiguration nicht mehr benötigt |
| `lib/src/beginning/utilities/set_ringtone.dart` | 6 | `import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';` | `import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';` | Import auf neues Paket |
| `lib/src/beginning/utilities/set_ringtone.dart` | 24 | `final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();` | *(entfernt)* | `FFmpegKit` ist statisch, keine Instanz nötig |
| `lib/src/beginning/utilities/set_ringtone.dart` | 27–29 | `flutterFFmpeg.execute(…).then((rc) => …)` | `await FFmpegKit.execute(…); debugPrint(…)` | Neue statische Execute-API |
| `lib/src/beginning/utilities/set_ringtone.dart` | 36–38 | `flutterFFmpeg.execute(…).then((rc) => …)` | `await FFmpegKit.execute(…); debugPrint(…)` | Fade-In für FLAC-Dateien |
| `lib/src/beginning/utilities/set_ringtone.dart` | 52–56 | `flutterFFmpeg.execute(…)` (2×) | `await FFmpegKit.execute(…)` (2×) | Konvertierung + Fade für Nicht-FLAC |

## Integration Test

`integration_test/packages/migration_ffmpeg_kit_flutter_new_test.dart`
