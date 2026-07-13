# material_design_icons_flutter

**Alt → Neu:** `material_design_icons_flutter: ^5.0.6996` → `material_design_icons_flutter: ^7.0.7296`

## Zweck der Migration

Version 7.x liefert aktualisierte MDI-Icons für Dart 3. `MdiIcons.*`-Getter sind in v7 nicht mehr `const`, daher muss `const Icon(MdiIcons.…)` zu `Icon(MdiIcons.…)` geändert werden.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 68 | `material_design_icons_flutter: ^5.0.6996` | `material_design_icons_flutter: ^7.0.7296` | Dart 3 / Flutter 3.44 compatibility version bump |
| `lib/src/beginning/pages/playlist/add_songs.dart` | 171–173 | `prefixIcon: const Icon(MdiIcons.playlistMusicOutline, …)` | `prefixIcon: Icon(MdiIcons.playlistMusicOutline, …)` | `MdiIcons` nicht mehr const-kompatibel |
| `lib/src/beginning/pages/settings/settings_pages/phoenix.dart` | 219–220 | `icon: const Icon(MdiIcons.gmail, …)` | `icon: Icon(MdiIcons.gmail, …)` | `MdiIcons` nicht mehr const-kompatibel |
| `lib/src/beginning/pages/settings/settings_pages/phoenix.dart` | 233–234 | `icon: const Icon(MdiIcons.github, …)` | `icon: Icon(MdiIcons.github, …)` | `MdiIcons` nicht mehr const-kompatibel |
| `lib/src/beginning/widgets/dialogues/double_tap.dart` | 39–42 | `icon: const Icon(MdiIcons.heart, …)` | `icon: Icon(MdiIcons.heart, …)` | `MdiIcons` nicht mehr const-kompatibel |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | 650–651 | `icon: const Icon(MdiIcons.heart, …)` | `icon: Icon(MdiIcons.heart, …)` | `MdiIcons` nicht mehr const-kompatibel |

## Integration Test

`integration_test/packages/migration_material_design_icons_flutter_test.dart`
