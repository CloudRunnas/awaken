# Migration Summary — Zweck jeder `docs/migration_*.md`

Diese Datei erklärt den Zweck jeder Migrations-Doku-Datei. Sie ist die “Landkarte” der Migration: **welches Dokument** beschreibt **welchen Paket-/SDK-Teil** und welche Art Änderung.

> Für Zeilen-/Hunk-Zuordnung siehe `docs/migration_index.md`.

---

## SDK / Toolchain

- **`migration_sdk_dart.md`**: Dart/Flutter SDK Constraint, API-Breaks in Flutter 3 (z. B. `WillPopScope`→`PopScope`, `WidgetStateProperty`, Deprecations).
- **`migration_sdk_android.md`**: Android Build Toolchain (AGP/Gradle/Kotlin DSL), Wrapper, Namespaces, compileSdk Floor, CI-Setup.

## Test-Infrastruktur

- **`migration_integration_test.md`**: Einführung/Organisation der `integration_test`-Validierung für Abhängigkeiten; Harness und Paket-Tests.

## Dependency-Version-Bumps / Replacements (pro Paket)

Jede Datei dokumentiert:
- Alt→Neu Version (oder Replacement)
- Zweck der Migration
- konkrete Code-/Config-Anpassungen (welche Datei/Zeilen, warum)

Pakete:
- **`migration_flutter_lints.md`**: Lints Update (Analyzer Regeln, CI).
- **`migration_another_flushbar.md`**
- **`migration_another_xlider.md`**
- **`migration_page_transition.md`**
- **`migration_palette_generator.md`**
- **`migration_sleek_circular_slider.md`**
- **`migration_audio_service.md`**: Audio Service + Foreground Playback Anforderungen.
- **`migration_ffmpeg_kit_flutter_new.md`**: Ersatz `flutter_ffmpeg` → `ffmpeg_kit_flutter_new` (native build kompatibel).
- **`migration_just_audio.md`**: `just_audio` Update + API-Konstruktor-Änderung.
- **`migration_on_audio_query.md`**: Query/MediaStore Anpassungen + Permissions.
- **`migration_on_audio_edit.md`**: Legacy Plugin (discontinued) + notwendige CI-Patches.
- **`migration_device_info_plus.md`**: `device_info` → `device_info_plus`.
- **`migration_image_picker.md`**
- **`migration_path_provider.md`**
- **`migration_permission_handler.md`**: neue Android Permission Model (Android 13+).
- **`migration_provider.md`**
- **`migration_share_plus.md`**: API Umstellung (`shareFiles` → `shareXFiles`).
- **`migration_flutter_displaymode.md`**: DisplayMode + compileSdk/AGP Kompatibilität.
- **`migration_cupertino_icons.md`**
- **`migration_flutter_launcher_icons.md`**
- **`migration_ionicons.md`**: `ionicons` → `ionicons_plus` + `IconData` final.
- **`migration_material_design_icons_flutter.md`**: Icon Paketwechsel wegen `IconData` final / Deprecations.
- **`migration_http.md`**
- **`migration_html.md`**
- **`migration_url_launcher.md`**
- **`migration_awesome_notifications.md`**
- **`migration_screenshot.md`**

## Index / Status

- **`migration_index.md`**: authoritative Zuordnung *jedes* `git diff 3ff5975` Hunks zu genau einem Migrationsdokument.
- **`migration_status.md`**: Fortschritt/CI-Verlauf, Blocker und Fix-Historie, „wie weiter“-Anleitung.

