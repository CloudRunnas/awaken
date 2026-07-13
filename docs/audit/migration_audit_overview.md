# Migration Audit — Überblick (Baseline `3ff5975` → HEAD)

Ziel dieses Audits: **jede Zeile**, die sich seit `3ff5975` geändert hat, muss eindeutig begründet sein:

- **Welche Library / welches Tooling** (Flutter/Dart/Gradle/AGP/Kotlin/CI) ist der Auslöser?
- **Warum** musste die Zeile geändert werden (Blocker, Kompatibilität, Bugfix)?
- **SDK-Bezug**: Betraf es Dart/Flutter SDK, Android/Gradle, Java/Kotlin Toolchain oder nur App-Logik?
- **Metadateien**: Welche Änderungen sind *nur* generiert/konfig (Lockfiles, Firebase, Cursor-Plan)?

Dieses Audit baut auf vorhandener Migrations-Doku auf:

- **Hunk-zu-Doc Mapping**: `docs/migration_index.md` ordnet die meisten Code-/Build-Hunks bereits einem Paket-/SDK-Dokument zu.
- **Status/CI-Historie**: `docs/migration_status.md` listet Blocker/Fixes im Zeitverlauf.

Für das Audit wurden zusätzliche Audit-Dokumente eingeführt:

- `docs/audit/diff_hunks_critical.md`: alle Hunks der **produktiven** Dateien (Build/CI/Skripte/`lib/`/`pubspec.yaml`)
- `docs/audit/build_ci_gradle_justification.md`: Begründung **aller Android/Gradle/Kotlin/JVM17** Änderungen (inkl. Kotlin-“Downgrade”)
- `docs/audit/patches_and_scripts.md`: Begründung **jedes Patch-Skripts** (warum nötig, Risiko, Alternativen)
- `docs/metafiles_changed.md`: Begründung der Metadateien (z. B. `pubspec.lock`, Firebase JSONs)
- `docs/migration_summary.md`: Zweck jeder `docs/migration_*.md`

> Hinweis: Dokumentations-Dateien (`docs/migration_*.md`, `docs/bugs/*.md`) werden im Audit als **Artefakte der Migration** betrachtet; ihre Zeilen werden als „Doku-Erstellung“ begründet, nicht als Produktionsänderung.

