# Migration Audit — Diff Hunks (kritische Dateien) `3ff5975..HEAD`

Diese Datei listet **alle Diff-Hunks** (alt→neu Zeilenspannen) für Dateien, die **Produktionscode/Build/CI** betreffen.

**Regel:** Jede geänderte Zeile innerhalb der unten aufgeführten Bereiche ist durch die referenzierte „Justification Source“ begründet.

Nicht-kritische Artefakte (z. B. `pubspec.lock`, `docs/migration_*.md`, `integration_test/*`) sind separat begründet:

- Lock/Config: `docs/metafiles_changed.md`
- Migrations-Doku: `docs/migration_summary.md`
- Test-Harness: `docs/migration_integration_test.md`

---

## `pubspec.yaml`

**Justification Source:** `docs/migration_index.md` (per-hunk Zuordnung) + jeweilige `docs/migration_*.md`

> Alle Hunks in `pubspec.yaml` sind im Index einzeln gemappt (SDK-Constraint + jede Dependency).

---

## `.github/workflows/build-apk.yml`

**Justification Source:** `docs/audit/build_ci_gradle_justification.md`

| Hunk | Alt (von–bis) | Neu (von–bis) |
|------|--------------|--------------|
| 1 | (neu) | 1–71 |

---

## Android Gradle / Toolchain

**Justification Source:** `docs/audit/build_ci_gradle_justification.md`

### `android/settings.gradle(.kts)`

| Datei | Hunk | Alt | Neu |
|------|------|-----|-----|
| `android/settings.gradle` | 1 | 1–11 | (gelöscht) |
| `android/settings.gradle.kts` | 1 | (neu) | 1–30 |

### `android/build.gradle(.kts)`

| Datei | Hunk | Alt | Neu |
|------|------|-----|-----|
| `android/build.gradle` | 1 | 1–35 | (gelöscht) |
| `android/build.gradle.kts` | 1 | (neu) | 1–61 |

### `android/app/build.gradle(.kts)`

| Datei | Hunk | Alt | Neu |
|------|------|-----|-----|
| `android/app/build.gradle` | 1 | 1–81 | (gelöscht) |
| `android/app/build.gradle.kts` | 1 | (neu) | 1–77 |

### `android/gradle.properties`

| Hunk | Alt | Neu |
|------|-----|-----|
| 1 | 1–2 | 1–1 |
| 2 | 4–4 | 3–3 |

### `android/gradle/wrapper/gradle-wrapper.properties`

| Hunk | Alt | Neu |
|------|-----|-----|
| 1 | 1–1 | (entfernt/verschoben) |
| 2 | 3–3 | (entfernt/verschoben) |
| 3 | 5–5 | (entfernt/verschoben) |
| 4 | 6–5 | 4–5 |

### `android/app/src/main/AndroidManifest.xml`

| Hunk | Alt | Neu |
|------|-----|-----|
| 1 | 6–6 | 6–6 |
| 2 | 7–6 | 8–8 |
| 3 | 8–7 | 10–10 |
| 4 | 10–9 | 13–14 |
| 5 | 58–58 | 62–64 |

---

## `lib/` (Produktionscode)

**Justification Source:** `docs/migration_index.md` (pro Datei/Hunk) + für MP3-Fallback zusätzlich `docs/bugs/mp3_preprocess_plan.md`

### `lib/main.dart`

| Hunk | Alt | Neu |
|------|-----|-----|
| 1 | 22–21 | 23–25 |
| 2 | 25–24 | 29–29 |
| 3 | 29–29 | 32–31 |
| 4 | 30–29 | 34–41 |

### `lib/src/beginning/begin.dart`

| Hunk | Alt | Neu |
|------|-----|-----|
| 1 | 4–3 | 5–5 |
| 2 | 26–26 | 27–27 |
| 3 | 33–33 | 33–32 |
| 4 | 128–129 | 128–135 |

### `lib/src/beginning/utilities/audio_handlers/background.dart`

| Hunk | Alt | Neu |
|------|-----|-----|
| 1 | 1–0 | 2–3 |
| 2 | 2–1 | 5–5 |
| 3 | 3–2 | 7–7 |
| 4 | 11–15 | 15–15 |
| 5 | 21–20 | 22–22 |
| 6 | 74–74 | 75–75 |
| 7 | 100–100 | 101–195 |
| 8 | 240–241 | 334–333 |

> Die neuen Hunks (7) sind **Bugfix/Feature** (MP3 Preprocess-Fallback) und werden in `docs/bugs/mp3_preprocess_plan.md` und `docs/bugs/mp3_scene_rip_playback_failure.md` begründet.

### Weitere `lib/*` Änderungen

Alle übrigen `lib/`-Änderungen sind im `docs/migration_index.md` pro Datei/Hunk zugeordnet (WillPopScope→PopScope, IconData final, Share API, Permission API, Screenshot import, etc.).

---

## `scripts/` (CI-/Local-Patches)

**Justification Source:** `docs/audit/patches_and_scripts.md`

- `scripts/patch_android_namespaces.sh`
- `scripts/patch_on_audio_edit_kotlin.sh`
- `scripts/patch_legacy_compile_sdk.sh`
- `scripts/patch_flutter_displaymode.sh`
- `scripts/run_integration_tests.sh`
- `scripts/setup_android_emulator.sh`
- `scripts/local_test_env.sh`
- `scripts/integration_test_status.sh`

---

## `test/widget_test.dart`

**Justification Source:** `docs/audit/migration_audit_overview.md`

Diese Änderungen sind Test-Template-Anpassungen (Flutter 3 Standard).

