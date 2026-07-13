# Warnungen aus GitHub Actions — Analyse & TODOs

Quelle: letzter erfolgreicher Workflow-Run „Build APK“.

Diese Datei sammelt **Warnungen** (Build- und Analyzer-Ausgaben), ordnet sie nach Häufigkeit, schätzt den Aufwand und bewertet den Impact.

---

## Build-Warnungen (Nicht-Flutter-Analyzer)

### 1) Node.js Deprecations (Firebase Distribution Action)

Beobachtet:
- **3×** `The punycode module is deprecated...`
- **2×** ``url.parse()` behavior is not standardized...``

**Quelle:** GitHub Action `wzieba/Firebase-Distribution-Github-Action@v1` läuft in einem Container/Node Kontext und gibt Node Deprecation Warnings aus.

- **Häufigkeit:** 5 pro Run
- **Aufwand:** Niedrig
- **Impact:** Minimal auf App/Build; betrifft Deployment-Action.
- **TODO:** Updaten/ersetzen der Action-Version oder alternative App Distribution Pipeline prüfen.

### 2) Kotlin-Version Drop-Warnung (Flutter Tooling)

Beobachtet:
- **1×** „Flutter support for your project's Kotlin version (2.2.10) will soon be dropped…“

**Interpretation:** Flutter Tooling detektiert Kotlin Version aus dem Build-Graph. Im Repo ist in `android/settings.gradle.kts` Kotlin **1.9.24** gepinnt; einige Plugins bringen aber eigene KGP/Metadata in den Build ein, wodurch Flutter eine höhere Version meldet.

- **Häufigkeit:** 1 pro Run
- **Aufwand:** Mittel
- **Impact:** Zukunftsrisiko — bei Flutter Updates kann die Toolchain strenger werden.
- **TODO:** Ermitteln, woher 2.2.10 kommt (welches Plugin / welches Gradle include) und konsolidieren.

### 3) Plugins wenden Kotlin Gradle Plugin an (KGP)

Beobachtet:
- **1×** Liste: `device_info_plus`, `ffmpeg_kit_flutter_new`, `on_audio_edit`, `on_audio_query_android`, `share_plus`

- **Häufigkeit:** 1 pro Run
- **Aufwand:** Mittel
- **Impact:** Potenziell relevant für künftige Kotlin/Gradle Upgrades; aktuell Build grün.
- **TODO:** Prüfen, ob Plugins unnötig eigene Kotlin Plugin Konfiguration einbringen (und ob wir zentral pinnen können).

---

## `flutter analyze` Infos (nach Regel, Häufigkeit)

Aus dem Log aggregiert:

| Regel | Häufigkeit | Aufwand | Impact |
|------|-----------:|---------|--------|
| `deprecated_member_use` | 134 | Mittel–Hoch | Kurzfristig gering (CI erlaubt Infos), langfristig Upgrade-Risiko |
| `use_super_parameters` | 51 | Niedrig–Mittel | Reine Code-Modernisierung, kein Runtime-Impact |
| `unnecessary_import` | 3 | Niedrig | Kein Runtime-Impact |
| `file_names` | 1 | Niedrig | Style/Tooling; kann Imports beeinflussen |
| `dangling_library_doc_comments` | 1 | Niedrig | Doku/Style |

### TODO-Block (priorisiert)

1. **`deprecated_member_use` reduzieren** (größter Blocker für “strengeres analyze”)
   - Kommentar: Viele Deprecations hängen an Flutter 3 API-Änderungen (`withOpacity`, `MaterialStateProperty`, etc.).
2. **Kotlin Versionswarnung auflösen** (2.2.10 vs Pin 1.9.24)
   - Kommentar: Vor zukünftigen Flutter Updates sauber ziehen.
3. **`use_super_parameters`** optional automatisieren
   - Kommentar: Safe-Refactor, kann per `dart fix` batch erfolgen.

