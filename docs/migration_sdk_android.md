# Android SDK / Gradle Migration

**Alt → Neu:** Groovy-Gradle (AGP 7.1.2, Gradle 7.3.3, Kotlin 1.6.21, compileSdk 33) → Kotlin-DSL (AGP 8.7.3, Gradle 8.11.1, Kotlin 2.1.0, Flutter-managed SDK)

## Zweck der Migration

Android-Build auf Flutter-3.44-Standard migrieren: Kotlin-DSL-Gradle-Dateien, Java 17, aktuelle Plugin-Architektur und Android-13+-Berechtigungen für Medien/Foreground-Service.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `android/app/build.gradle` | 1–81 | Groovy `build.gradle` | *(gelöscht)* | Ersetzt durch Kotlin-DSL |
| `android/app/build.gradle.kts` | 1–71 | *(nicht vorhanden)* | Kotlin-DSL App-Modul | Flutter-3-Gradle-Plugin, `namespace`, Java 17 |
| `android/app/build.gradle.kts` | 17–18 | `compileSdkVersion 33` | `compileSdk = flutter.compileSdkVersion` | SDK-Version über Flutter-Toolchain |
| `android/app/build.gradle.kts` | 21–28 | *(nicht vorhanden)* | `compileOptions` / `kotlinOptions` Java 17 | AGP 8 / JDK-17-Anforderung |
| `android/app/build.gradle.kts` | 37 | `targetSdkVersion 33` | `targetSdk = flutter.targetSdkVersion` | Target-SDK über Flutter-Toolchain |
| `android/app/build.gradle.kts` | 70 | `lifecycle-viewmodel-ktx:2.4.0` | `lifecycle-viewmodel-ktx:2.8.7` | Aktualisierte AndroidX-Abhängigkeit |
| `android/build.gradle` | 1–35 | Groovy Root-Build | *(gelöscht)* | Ersetzt durch `build.gradle.kts` |
| `android/build.gradle.kts` | 1–24 | *(nicht vorhanden)* | Kotlin-DSL Root-Build | Vereinfachtes Root-Projekt ohne `flutterFFmpegPackage` |
| `android/build.gradle` | 22–24 | `flutterFFmpegPackage = "min"` | *(entfernt)* | `flutter_ffmpeg` entfernt; nicht mehr benötigt |
| `android/settings.gradle` | 1–11 | Groovy Settings | *(gelöscht)* | Ersetzt durch `settings.gradle.kts` |
| `android/settings.gradle.kts` | 1–26 | *(nicht vorhanden)* | Plugin-Management + Flutter-Loader | Flutter-3-Plugin-Architektur (AGP 8.7.3, Kotlin 2.1.0) |
| `android/settings_aar.gradle` | 1 | `include ':app'` | *(gelöscht)* | Veraltete AAR-Settings, nicht mehr benötigt |
| `android/gradle/wrapper/gradle-wrapper.properties` | 2 | `gradle-7.3.3-bin.zip` | `gradle-8.11.1-all.zip` | Gradle-Upgrade für AGP 8 |
| `android/app/src/main/AndroidManifest.xml` | 6 | `READ_EXTERNAL_STORAGE` (ohne maxSdk) | `android:maxSdkVersion="32"` | Scoped Storage: Legacy-Permission nur bis API 32 |
| `android/app/src/main/AndroidManifest.xml` | 7–9 | `WRITE_EXTERNAL_STORAGE` (ohne maxSdk) | `android:maxSdkVersion="32"` | Scoped Storage: Legacy-Schreibzugriff nur bis API 32 |
| `android/app/src/main/AndroidManifest.xml` | 10 | *(nicht vorhanden)* | `READ_MEDIA_AUDIO` | Android 13+ Medienzugriff (ersetzt Storage-Permission) |
| `android/app/src/main/AndroidManifest.xml` | 13 | *(nicht vorhanden)* | `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Android 14+ Foreground-Service-Typ für Audio |
| `android/app/src/main/AndroidManifest.xml` | 14 | *(nicht vorhanden)* | `POST_NOTIFICATIONS` | Android 13+ Benachrichtigungs-Runtime-Permission |
| `android/app/src/main/AndroidManifest.xml` | 62–64 | `AudioService` (ohne `foregroundServiceType`) | `android:foregroundServiceType="mediaPlayback"` | Android 14+ Media-Playback-Foreground-Service |

## Integration Test

Kein dedizierter Android-Gradle-Integrations-Test. Build-Validierung über `flutter build apk` / CI-Workflow.

## Verwandte Dokumentation

- [migration_permission_handler.md](migration_permission_handler.md) — Runtime-Permission `Permission.audio` / `Permission.storage`
- [migration_audio_service.md](migration_audio_service.md) — `AudioService` Foreground-Service-Typ
- [migration_awesome_notifications.md](migration_awesome_notifications.md) — `POST_NOTIFICATIONS`
