# ionicons

**Alt → Neu:** `ionicons: ^0.2.1` → `ionicons: ^0.2.2`

## Zweck der Migration

Dart 3 / Flutter 3.44 compatibility version bump.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 67 | `ionicons: ^0.2.1` | `ionicons: ^0.2.2` | Dart 3 / Flutter 3.44 compatibility version bump |
| `lib/src/beginning/pages/playlist/add_songs.dart` | 177–178 | `icon: const Icon(Ionicons.trash_outline, …)` | `icon: Icon(Ionicons.trash_outline, …)` | `Ionicons`-Getter nicht const-kompatibel in neuer Version |

## Integration Test

`integration_test/packages/migration_ionicons_test.dart`
