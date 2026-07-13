# Migration: on_audio_edit

| Feld | Wert |
|------|------|
| Paket | `on_audio_edit` |
| Alt | `^1.4.0+1` (unverändert in pubspec-Constraint) |
| Neu | `1.5.1` (via pub resolve) |
| Status | **Discontinued** — kein offizielles Flutter-3/AGP-9-Update |

## Zweck

`on_audio_edit` wird für Metadaten-/Tag-Bearbeitung in der App genutzt. Das Paket ist eingestellt, aber weiterhin als transitive Abhängigkeit von `on_audio_query` bzw. direkt in `pubspec.yaml` deklariert. Für AGP 9 / Kotlin 2.x schlagen die nativen Kotlin-Quellen fehl.

## Änderungen

### 1. Keine pubspec-Versionsänderung

```yaml
# pubspec.yaml (unverändert gegenüber Baseline-Constraint)
on_audio_edit: ^1.4.0+1
```

`pub get` löst auf `1.5.1` auf — letzte veröffentlichte Version.

### 2. CI-Patch-Script (neu)

**Datei:** `scripts/patch_on_audio_edit_kotlin.sh`

| Zeile / Block | Zweck |
|---------------|-------|
| Gesamte `OnWarningSizeCall.kt` | `when (true)` → exhaustives `when { … else -> {} }` (Kotlin 2.x) |
| `OnAudioEdit10.kt` Zeile `val pUri: Uri` | → `var pUri: Uri` (Captured-value-Initialisierung in Coroutine) |
| `OnArtworkEdit10.kt` Zeile `val pUri: Uri` | → `var pUri: Uri` (gleicher Fix) |

**Ausführung in CI:** `.github/workflows/build-apk.yml` — Schritt nach `patch_android_namespaces.sh`:

```yaml
- run: bash scripts/patch_on_audio_edit_kotlin.sh
```

### 3. Kotlin-Version (Android-Toolchain)

**Datei:** `android/settings.gradle.kts`

```kotlin
id("org.jetbrains.kotlin.android") version "1.9.24" apply false
```

Kotlin 2.3 kompiliert `on_audio_edit` 1.5.1 nicht; Pin auf 1.9.24 als Workaround.

## Betroffene App-Dateien

Keine Dart-Änderungen in `lib/` — nur nativer Plugin-Code wird im CI gepatcht.

## Integrations-Test

`integration_test/packages/migration_on_audio_edit_test.dart` — Smoke-Test der Plugin-API.

## Git-Diff-Zuordnung

| Hunk | Datei | Zweck |
|------|-------|-------|
| `scripts/patch_on_audio_edit_kotlin.sh` (neu) | CI Kotlin-Patch | |
| `.github/workflows/build-apk.yml` | Patch-Schritt eingefügt | |
| `android/settings.gradle.kts` | Kotlin 1.9.24 | Legacy-Plugin-Kompatibilität |
