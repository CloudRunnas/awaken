# share_plus

**Alt → Neu:** `share_plus: ^4.0.10+1` → `share_plus: ^10.1.4`

## Zweck der Migration

`share_plus` 10.x ersetzt `Share.shareFiles()` durch `Share.shareXFiles()` mit `XFile`-Objekten (cross_file-API).

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 53 | `share_plus: ^4.0.10+1` | `share_plus: ^10.1.4` | Dart 3 / Flutter 3.44 compatibility version bump |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | 272–278 | `Share.shareFiles([widget.listOfSong![…].data])` | `Share.shareXFiles([XFile(widget.listOfSong![…].data)])` | Neue Share-API mit `XFile` |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | 583–587 | `Share.shareFiles(['$appDocPath/legendary-er.png'])` | `Share.shareXFiles([XFile('$appDocPath/legendary-er.png')])` | Screenshot teilen mit `XFile` |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | 760–761 | `Share.shareFiles([nowMediaItem.id])` | `Share.shareXFiles([XFile(nowMediaItem.id)])` | Aktuellen Song teilen mit `XFile` |

## Integration Test

`integration_test/packages/migration_share_plus_test.dart`
