# just_audio

**Alt → Neu:** `just_audio: ^0.9.28` → `just_audio: ^0.10.4`

## Zweck der Migration

`just_audio` 0.10 entfernt veraltete `AudioPlayer`-Konstruktor-Parameter; Audio-Session und Unterbrechungen werden jetzt über `audio_session` automatisch verwaltet.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 42 | `just_audio: ^0.9.28` | `just_audio: ^0.10.4` | Dart 3 / Flutter 3.44 compatibility version bump |
| `lib/src/beginning/utilities/audio_handlers/background.dart` | 11 | `AudioPlayer(handleInterruptions: true, androidApplyAudioAttributes: true, handleAudioSessionActivation: true)` | `AudioPlayer()` | Entfernte Konstruktor-Parameter in just_audio 0.10 |

## Integration Test

`integration_test/packages/migration_just_audio_test.dart`
