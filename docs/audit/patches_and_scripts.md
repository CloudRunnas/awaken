# Patches & Scripts Audit — Begründung aller Patch-Dateien

Diese Datei begründet **jede Patch-/Script-Datei**, die in der Migration hinzugefügt wurde und den Build/CI beeinflusst.

---

## Grundprinzip

Mehrere Flutter-Plugins im Pub-Cache sind **Legacy** (discontinued oder nicht AGP-9-kompatibel). Statt Forks dauerhaft zu pflegen, werden sie im CI und lokal **vor dem Build** gepatcht.

Risiken:
- Patch-Skripte sind vom Upstream-Layout abhängig (Pfad/Dateinamen).
- `flutter pub cache` Inhalte ändern sich mit neuen Plugin-Versionen.

Mitigation:
- Patches sind gezielt, klein und idempotent.
- Dokumentation im Repo + Skripte in CI fixiert.

---

## `scripts/patch_android_namespaces.sh`

**Problem:** AGP 8+ verlangt `android.namespace` in Library-Modulen. Viele Flutter-Plugins haben keinen Namespace → Build bricht.

**Fix:** Script injiziert Namespace für betroffene Plugins im Pub-Cache.

**SDK betroffen?** Ja — AGP/Android Build.

---

## `scripts/patch_on_audio_edit_kotlin.sh`

**Problem:** `on_audio_edit` (discontinued) hat Kotlin-Code, der mit neuer Toolchain nicht mehr compiliert (u. a. mutability / Kotlin strenger).

**Fix:** Patch ersetzt/ändert konkrete Kotlin-Dateien (z. B. WarningSizeCall und `pUri` mutability).

**SDK betroffen?** Ja — Kotlin/AGP.

**Warum nicht einfach Plugin updaten?** Plugin ist discontinued; neuere Versionen sind nicht zuverlässig kompatibel, daher Patch als pragmatische Stabilisierung.

---

## `scripts/patch_legacy_compile_sdk.sh`

**Problem:** Einige Plugins pinnen `compileSdkVersion` hart auf 30/33; bei neuem AGP führt das zu `checkReleaseAarMetadata` und ähnlichen Fehlern.

**Fix:** Script ersetzt `compileSdkVersion (30|31|32|33)` → `34` in Pub-Cache Plugins:
- `on_audio_edit-*`
- `on_audio_query_android-*`
- `flutter_displaymode-*`

**SDK betroffen?** Ja — Android SDK / compileSdk.

---

## `scripts/patch_flutter_displaymode.sh`

**Historisch:** Spezifischer Patch nur für `flutter_displaymode` (compileSdk).

**Status:** Inzwischen durch `patch_legacy_compile_sdk.sh` generalisiert; bleibt als Dokumentations-/Legacy-Artefakt erhalten.

---

## `scripts/run_integration_tests.sh`, `scripts/setup_android_emulator.sh`, `scripts/local_test_env.sh`, `scripts/integration_test_status.sh`

**Zweck:** Lokale Integrationstest-Infrastruktur (nicht primär CI), um Paket-Kompatibilität nach Migration zu validieren.

**Warum im Repo?** Wiederholbare, dokumentierte Ausführung; reduziert “works on my machine”.

**SDK betroffen?** Indirekt (Android Emulator/SDK), aber nicht Produktionscode.

---

## `scripts/generate_mp3_test_matrix.sh`

**Zweck:** Bug-Diagnostik für MP3 Scene-Rip Abspielproblem: automatisiert isolierte Test-Encodes erzeugen.

**Begründung:** Dient reproduzierbarer Root-Cause Analyse, keine App-Build-Abhängigkeit.

