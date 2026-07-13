# Build/CI/Gradle Audit — Begründung aller Android-Toolchain Änderungen

Baseline: `3ff5975` (Flutter 2) → Ziel: Flutter 3.44.1 / Dart 3 / AGP 9 / Gradle 9 / Java 17.

Diese Datei begründet **jede Änderung** in:

- `.github/workflows/build-apk.yml`
- `android/**` (Kotlin DSL, Wrapper, Properties, Manifest)
- `android/app/google-services.json`, `firebase.json` (Konfig; Details in `docs/metafiles_changed.md`)

---

## Warum Kotlin DSL (`*.gradle.kts`)?

**Änderung:** Groovy `build.gradle`/`settings.gradle` wurden gelöscht, Kotlin DSL Dateien hinzugefügt.

**Library/Tooling:** Flutter 3.44 Templates + Android Gradle Plugin 9.

**Warum:** Flutter/AGP setzen zunehmend auf Kotlin DSL; es reduziert Template-Divergenz und ist kompatibler mit aktuellen Gradle/AGP APIs.

**SDK betroffen?** Ja — Android Build Toolchain (Gradle/AGP).

Betroffene Dateien:
- `android/settings.gradle` → `android/settings.gradle.kts`
- `android/build.gradle` → `android/build.gradle.kts`
- `android/app/build.gradle` → `android/app/build.gradle.kts`

---

## Warum JVM 17?

**Änderung:** Java/Kotlin Compile Targets auf 17 gesetzt.

Quellen:
- `android/build.gradle.kts`: `compileOptions { sourceCompatibility/targetCompatibility = VERSION_17 }`
- `android/build.gradle.kts`: Kotlin `jvmTarget = JVM_17`
- `android/app/build.gradle.kts`: `compileOptions VERSION_17` + Kotlin `jvmTarget JVM_17`
- `.github/workflows/build-apk.yml`: `setup-java` auf 17

**Library/Tooling:** AGP 9 / Gradle 9 erwarten eine moderne Toolchain; viele Plugins/Deps bauen sauber nur mit Java 17.

**Warum:** In der Migration traten Plugin-Build-Probleme mit niedrigerem Target auf; Java 17 ist die stabilste CI-Default für Flutter 3.44 + aktuelle Android-Toolchain.

**SDK betroffen?** Ja — Android/Java Toolchain.

---

## Kotlin “Downgrade” — was bedeutet das hier?

In `android/settings.gradle.kts` ist Kotlin Plugin Version **1.9.24** gesetzt:

```kts
id("org.jetbrains.kotlin.android") version "1.9.24" apply false
```

**Library/Tooling:** Kotlin Gradle Plugin (KGP).

**Warum:** Konkreter Blocker war `on_audio_edit` (discontinued) und dessen Android-Unterprojekt, das in neueren Kotlin/AGP Kombinationen Fehler wirft. Kotlin 1.9.24 ist ein kompatibles “Floor”, das mit AGP 9 funktioniert und Legacy-Plugin-Code weniger aggressiv bricht.

**SDK betroffen?** Ja — Kotlin/Android Toolchain.

**Blocker für neuere Kotlin-Versionen:**
- Strengere Kotlin 2.x Checks und API-Änderungen schlagen in Legacy Plugins durch.
- Das Repo nutzt derzeit bewusst Patch-Skripte (`scripts/patch_on_audio_edit_kotlin.sh`) um Legacy-Code zu reparieren; ein Kotlin-Update ohne Upstream-Fix würde diese Patches erweitern/ersetzen müssen.

---

## Gradle Wrapper / AGP Versionen

### Gradle
`android/gradle/wrapper/gradle-wrapper.properties` zeigt:

```properties
distributionUrl=https://services.gradle.org/distributions/gradle-9.1.0-all.zip
```

**Warum:** AGP 9 benötigt eine aktuelle Gradle-Version. Die Migration richtet sich am Flutter 3.44 / AGP 9 Template aus.

**SDK betroffen?** Ja — Android Build Toolchain.

### AGP
In `android/settings.gradle.kts`:

```kts
id("com.android.application") version "9.0.1" apply false
```

**Warum:** Kompatibel zu Gradle 9 und Flutter 3.44; entspricht dem Ziel “aktuelle Android Toolchain”.

---

## Warum `compileSdk`-Patches / compileSdk >= 34?

In `android/build.gradle.kts` wird für Library-Subprojects erzwungen:

```kts
if (compileSdk == null || compileSdk!! < 34) {
  compileSdk = 34
}
```

**Problem:** Manche Flutter-Plugins pinnen `compileSdkVersion` hart im eigenen `android/build.gradle` (z. B. 30/33). Bei neuen AGP-Versionen führt das zu `checkReleaseAarMetadata` Fehlern.

**Warum reicht die Gradle-Override manchmal nicht?** Einige Plugins überschreiben es so, dass Overrides nicht greifen → daher zusätzlich `scripts/patch_legacy_compile_sdk.sh`.

**SDK betroffen?** Ja — Android SDK / compileSdk Policy.

---

## AndroidManifest — neue Permissions/Services

Betroffene Datei: `android/app/src/main/AndroidManifest.xml`

**Library/Tooling:**
- `permission_handler` auf Android 13+ (`READ_MEDIA_AUDIO`)
- `audio_service`/Foreground Playback (`FOREGROUND_SERVICE_MEDIA_PLAYBACK`)
- `awesome_notifications` (`POST_NOTIFICATIONS`)

**Warum:** Android 13/14 Permission Model & Foreground Service Types sind verpflichtend für korrekte Funktion.

**SDK betroffen?** Ja — Android API Level Behaviour.

---

## CI Workflow — warum diese Schritte?

Datei: `.github/workflows/build-apk.yml`

**Wesentliche Entscheidungen:**
- Java 17 installieren (AGP/Gradle kompatibel)
- Flutter 3.44.1 pinnen (definierter Zielstand)
- `flutter pub get`
- Patch-Skripte ausführen (Namespaces, Kotlin Fixes, compileSdk Fixes)
- `flutter analyze --no-fatal-*` (CI pragmatisch grün halten, Infos/Warnungen nicht fatal)
- Release APK Build (split-per-abi)
- Upload Artifact + Firebase App Distribution Deploys

**SDK betroffen?** Ja — CI Toolchain und Android Build.

---

## Jede Gradle-Anpassung (Kurzliste)

### `android/app/build.gradle.kts`
- Plugins: `com.google.gms.google-services`, `firebase-crashlytics`, `dev.flutter.flutter-gradle-plugin`
- Java 17 Compile Options
- Release: `isMinifyEnabled=false`, `isShrinkResources=false` (R8/Play-Core Blocker in Migration)

### `android/build.gradle.kts`
- `namespace` Auto-Fix für Legacy Plugins (AGP 8+ Anforderung)
- `compileSdk` Floor 34 für Legacy Plugins
- Java/Kotlin Target 17

### `android/settings.gradle.kts`
- Plugin Versions (AGP 9.0.1, Kotlin 1.9.24, Flutter plugin loader)
- Flutter includeBuild

---

## Blocker / Herausforderungen bei Updates

Wenn wir “einfach alles” auf neueste Versionen ziehen (Kotlin 2.x, neuere AGP, neuere Plugins), drohen:

- **Legacy Plugins** ohne Namespace/compileSdk Fixes: Build bricht.
- **Discontinued Plugins** (`on_audio_edit`, `palette_generator`): Upstream Fixes fehlen; Migration bleibt Patch-getrieben.
- **R8/Minify**: kann erneut Play-Core/ProGuard Themen auslösen (bisher bewusst deaktiviert).

