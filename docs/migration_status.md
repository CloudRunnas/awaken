# Flutter-3-Migration — Fortschrittsbericht (Handoff)

> **Stand:** 2026-07-13 · **Branch:** `main` · **Letzter Commit:** `0536578`  
> **Baseline:** `3ff5975` — *chore: import The Phoenix Project source (Flutter 2 baseline)*  
> **Ziel:** Flutter **3.44.1**, Dart **3.x**, grüner CI-APK-Build ohne Firebase App Distribution

Dieses Dokument fasst den aktuellen Migrationsstand zusammen, damit die Arbeit später nahtlos fortgesetzt werden kann. Detail-Diffs pro Paket stehen in den jeweiligen `migration_*.md`-Dateien; der Index ist in [migration_index.md](migration_index.md).

---

## Kurzfassung

| Bereich | Status |
|---------|--------|
| Quellrepo importieren & pushen | ✅ Erledigt |
| SDK + `pubspec.yaml` migrieren | ✅ Erledigt |
| Discontinued Pakete ersetzen + Code | ✅ Erledigt |
| Android Gradle/AGP/Kotlin (Kotlin-DSL) | ✅ Erledigt |
| Integrationstests pro Paket | ✅ Erledigt (~30 Tests) |
| `docs/migration_*.md` pro Paket | ✅ Erledigt (31 Dateien) |
| GitHub Actions Workflow | ✅ Eingerichtet |
| **CI APK-Build grün** | ⏳ **Offen** — letzter Fix gepusht, Run war beim Handoff noch aktiv |

---

## Repository & Branches

| Remote | URL |
|--------|-----|
| `origin` | https://github.com/CloudRunnas/awaken |
| Quelle (historisch) | https://github.com/shaan-mephobic/the-phoenix-project (`master`) |

- Paketname bleibt **`phoenix`** (unverändert).
- UI soll nicht maßgeblich verändert werden (`useMaterial3: false`).

---

## Was erledigt ist

### 1. Repository-Import
- Phoenix-Code nach `awaken` geklont und als Baseline committed (`3ff5975`).
- Migration auf `main` mit 16 weiteren Commits seit Baseline.

### 2. SDK & Dependencies (`pubspec.yaml`)

| Alt | Neu / Ersatz |
|-----|--------------|
| `sdk: '>=2.12.0 <3.0.0'` | `sdk: '>=3.5.0 <4.0.0'` |
| `device_info` | `device_info_plus: ^11.3.0` |
| `flutter_ffmpeg` | `ffmpeg_kit_flutter_new: ^4.4.2` |
| `on_audio_query: 2.6.1` | `on_audio_query: ^2.9.0` |
| `ionicons` | `ionicons_plus: ^0.2.5` |
| `material_design_icons_flutter` | `flutter_material_design_icons: ^3.1.0+7447` |
| `flare_flutter` / `flare_loading` | **entfernt** (Loader durch `_DiscLoader` ersetzt) |
| Alle übrigen Pakete | Version bumps — siehe [migration_index.md](migration_index.md) |

`dependency_overrides`: `flutter_plugin_android_lifecycle: ^2.0.35`

### 3. Code-Änderungen (`lib/`)

| Datei | Änderung |
|-------|----------|
| `lib/main.dart` | `Paint.enableDithering` entfernt |
| `lib/src/beginning/utilities/constants.dart` | `useMaterial3: false`, `WidgetStateProperty` |
| `lib/src/beginning/utilities/init.dart` | `device_info_plus`, `requestMusicLibraryPermission()` |
| `lib/src/beginning/utilities/set_ringtone.dart` | `FFmpegKit.execute()` statt `FlutterFFmpeg` |
| `lib/src/beginning/utilities/audio_handlers/background.dart` | `AudioPlayer()` vereinfacht, exhaustive switch |
| `lib/src/beginning/begin.dart` | `WillPopScope` → `PopScope` |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | `Share.shareXFiles`, Permissions via `init.dart` |
| `lib/src/beginning/widgets/dialogues/awakening.dart` | `FlareLoading` → `_DiscLoader` |
| Diverse | `const Icon` bei MdiIcons/Ionicons entfernt |

### 4. Android-Toolchain

- Gradle Groovy → **Kotlin DSL** (`settings.gradle.kts`, `build.gradle.kts`, `app/build.gradle.kts`)
- Gradle Wrapper **9.1.0**, AGP **9.0.1**, Kotlin **1.9.24** (Legacy-Plugin-Kompatibilität)
- `AndroidManifest.xml`: `READ_MEDIA_AUDIO`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `POST_NOTIFICATIONS`
- `gradle.properties`: Heap 4 GB, `enableJetifier=false`, `enableR8` entfernt
- Release: `isMinifyEnabled = false`, `isShrinkResources = false` (R8 Play-Core-Workaround)

### 5. CI-Patch-Skripte (`scripts/`)

Diese Skripte patchen Legacy-Plugins im Pub-Cache **vor** `flutter build apk`:

| Skript | Zweck | Dokument |
|--------|-------|----------|
| `patch_android_namespaces.sh` | Fehlende Android-Namespaces für AGP 9 | [migration_sdk_android.md](migration_sdk_android.md) |
| `patch_on_audio_edit_kotlin.sh` | Kotlin-Fixes in `on_audio_edit` 1.5.1 | [migration_on_audio_edit.md](migration_on_audio_edit.md) |
| `patch_flutter_displaymode.sh` | `compileSdkVersion 33` → `34` | [migration_flutter_displaymode.md](migration_flutter_displaymode.md) |

### 6. GitHub Actions (`.github/workflows/build-apk.yml`)

```
flutter pub get
→ patch_android_namespaces.sh
→ patch_on_audio_edit_kotlin.sh
→ patch_flutter_displaymode.sh
→ flutter analyze --no-fatal-infos --no-fatal-warnings
→ flutter build apk --release
→ upload-artifact: release-apk
```

Flutter-Version in CI: **3.44.1**, Java **17**.

### 7. Integrationstests

Unter `integration_test/packages/migration_*_test.dart` — Harness in `integration_test/support/package_test_harness.dart`.

### 8. Dokumentation

31 Dateien `docs/migration_*.md` + [migration_index.md](migration_index.md) mit Hunk-Zuordnung zu `git diff 3ff5975`.

---

## CI-Verlauf & behobene Fehler

| # | Fehler | Fix (Commit) |
|---|--------|--------------|
| 1 | 188 Analyzer-Issues | `--no-fatal-infos --no-fatal-warnings` + Warning-Fixes (`59d0e21`) |
| 2 | `android.enableR8` deprecated | Entfernt (`c192c60`) |
| 3 | Fehlende Plugin-Namespaces (AGP 9) | `patch_android_namespaces.sh` + Gradle-Map (`33d1a0b`, `eb24fdb`) |
| 4 | `IconData` final (Flutter 3.44) | `ionicons_plus`, `flutter_material_design_icons`, Flare entfernt (`56ecab4`) |
| 5 | Java heap space / Jetifier | Heap 4 GB, Jetifier aus (`653f2b1`) |
| 6 | `ffmpeg_kit_flutter_android` Java-Fehler | Upgrade auf `^4.4.2` (`a71e506`) |
| 7 | JVM 11 vs 17 in Plugins | JVM 17 in `pluginManager` (`4ef6da6`, `909aa0e`) |
| 8 | `on_audio_edit` Kotlin 2.x | Kotlin 1.9.24 + CI-Patch (`a9834a8`, `6b7fef3`) |
| 9 | R8 fehlende Play-Core-Klasse | `isMinifyEnabled = false` (`6c1d7e3`) |
| 10 | `flutter_displaymode` compileSdk 33 | Gradle-Override + CI-Patch (`6c1d7e3`, `0536578`) |

### Letzter CI-Stand beim Handoff

- **Commit:** `0536578` — *fix: patch flutter_displaymode compileSdk to 34 in CI*
- **Run:** https://github.com/CloudRunnas/awaken/actions/runs/29251214755 (Run #17)
- **Status beim Abbruch:** `in_progress` — `flutter analyze` grün, APK-Build lief noch
- **Artifact `release-apk`:** noch nicht hochgeladen (Build nicht abgeschlossen)

**Erster Schritt beim Fortsetzen:** CI-Run #17 (oder neueren Run auf `main`) prüfen — Erfolg oder nächsten Gradle-Fehler analysieren.

---

## Offene Aufgaben (Priorität)

### P0 — CI grün bekommen
1. Ergebnis von Run `29251214755` (oder aktuellstem Run) prüfen.
2. Bei Erfolg: APK-Artifact verifizieren, ggf. lokal/manuell testen.
3. Bei Fehler: Gradle-Log analysieren → weiteres Patch-Skript oder Dependency-Upgrade.

**Mögliche nächste Blocker** (basierend auf bisherigem Verlauf):
- Weitere Legacy-Plugins mit `compileSdk < 34` (analog `flutter_displaymode` patchen)
- `awesome_notifications`, `on_audio_query` native Kotlin/Java-Probleme
- Weitere R8/ProGuard-Themen falls Minify wieder aktiviert wird

### P1 — Nach grünem Build
- [ ] Integrationstests in CI optional einbinden (`flutter test integration_test/...`)
- [ ] `flutter analyze` wieder ohne `--no-fatal-warnings` (Warnings schrittweise beheben)
- [ ] Plan-Datei `.cursor/plans/flutter_3_migration_awaken_169f0d1e.plan.md` Todos auf `completed` setzen

### P2 — Optional / langfristig
- `on_audio_edit` durch maintained Alternative ersetzen (Paket ist discontinued)
- iOS-Build prüfen (bisher nur Android/CI fokussiert)
- Release-Signing (`key.properties`) für echte Release-APKs

---

## So setzt du die Migration fort

Sage dem Agenten z. B.:

> „Setze die Flutter-3-Migration fort. Lies `docs/migration_status.md` und bring den CI APK-Build zum Erfolg.“

Der Agent sollte dann:

1. `docs/migration_status.md` und [migration_index.md](migration_index.md) lesen
2. Letzten CI-Run auf `main` prüfen (GitHub Actions → Workflow **Build APK**)
3. Bei Fehler: Log analysieren, fixen, committen, pushen, wiederholen
4. Jede neue Änderung in passender `docs/migration_*.md` dokumentieren
5. `git diff 3ff5975` gegen [migration_index.md](migration_index.md) abgleichen

### Nützliche Befehle

```bash
# Diff seit Baseline
git diff 3ff5975 --stat

# CI-Workflow lokal simulieren (ohne Android SDK kein APK-Build)
flutter pub get
bash scripts/patch_android_namespaces.sh
bash scripts/patch_on_audio_edit_kotlin.sh
bash scripts/patch_flutter_displaymode.sh
flutter analyze --no-fatal-infos --no-fatal-warnings
```

**Hinweis:** Lokal war kein Android SDK installiert (`[!] No Android SDK found`). Verifikation erfolgt primär über GitHub Actions.

---

## Commit-Historie seit Baseline

```
0536578 fix: patch flutter_displaymode compileSdk to 34 in CI
6c1d7e3 fix: raise legacy plugin compileSdk and disable release R8 minify
6b7fef3 fix: patch on_audio_edit Kotlin sources in CI for AGP 9 builds
a9834a8 fix: use Kotlin 1.9.24 for legacy on_audio_edit plugin compatibility
909aa0e fix: set JVM 17 in pluginManager block without afterEvaluate
4ef6da6 fix: align JVM target 17 for legacy Flutter plugin subprojects
a71e506 fix: upgrade ffmpeg_kit_flutter_new to ^4.4.2 for AGP 9
653f2b1 fix: increase Gradle heap and disable Jetifier for CI APK build
56ecab4 fix: replace icon and flare packages for Flutter 3.44 IconData final
eb24fdb fix: patch legacy plugin namespaces for AGP 9 release builds
33d1a0b fix: inject Android namespace for legacy Flutter plugins
a350c78 fix: upgrade flutter_plugin_android_lifecycle for AGP 9 namespace
c192c60 fix: remove deprecated android.enableR8 for AGP 9
229c87f fix: align Android Gradle config with Flutter 3.44 template
59d0e21 fix: resolve analyzer warnings for CI and relax analyze step
a364e97 feat: migrate Phoenix to Flutter 3.44 with package updates
```

---

## Wichtige Dateipfade

```
awaken/
├── pubspec.yaml
├── .github/workflows/build-apk.yml
├── scripts/
│   ├── patch_android_namespaces.sh
│   ├── patch_on_audio_edit_kotlin.sh
│   └── patch_flutter_displaymode.sh
├── android/
│   ├── settings.gradle.kts
│   ├── build.gradle.kts
│   ├── app/build.gradle.kts
│   └── gradle.properties
├── docs/
│   ├── migration_status.md          ← dieses Dokument
│   ├── migration_index.md
│   └── migration_*.md               ← je Paket/Bereich
├── integration_test/packages/
└── lib/
```

---

## Referenzen

- Migrationsplan: `.cursor/plans/flutter_3_migration_awaken_169f0d1e.plan.md`
- Dokumentationsindex: [migration_index.md](migration_index.md)
- CI-Workflow: `.github/workflows/build-apk.yml`
