# Metadateien / generierte Dateien — Änderungen seit `3ff5975`

Diese Datei begründet Änderungen an Dateien, deren Inhalt **nicht** direkt “handgeschriebener” Produktionscode ist, sondern:

- durch Tooling generiert wird (Lockfiles, firebase options)
- Konfigurations-Artefakte darstellt (Firebase JSONs)
- IDE/Agent-Artefakte sind (Cursor Plan)

---

## `pubspec.lock`

**Warum geändert?** Automatisch generiert durch `flutter pub get` nach Dependency- und SDK-Updates.

**Welche Library?** Indirekt alle in `pubspec.yaml` geupdateten Dependencies.

**SDK betroffen?** Ja (Dart SDK Constraint + Dependency Solver), aber Datei selbst ist “Metadaten”.

**Policy:** Lockfile wird im Repo behalten, um reproduzierbare Builds zu gewährleisten.

---

## `android/app/google-services.json`

**Warum hinzugefügt/geändert?** Firebase Android App Konfiguration (Google Services Plugin).

**Welche Library?** `firebase_core`, `firebase_crashlytics`, App Distribution Workflow.

**SDK betroffen?** Android Build/Runtime (Firebase init).

**Sicherheitsaspekt:** Diese Datei enthält IDs/Keys für das Firebase-Projekt (üblich). Keine privaten Secrets, aber Projektbindung.

---

## `firebase.json`

**Warum hinzugefügt?** Firebase CLI/Projekt-Konfig (Crashlytics/App Distribution Tooling).

**SDK betroffen?** Nein (Tooling-Konfig).

---

## `lib/firebase_options.dart`

**Warum hinzugefügt?** Generiert durch FlutterFire CLI (`flutterfire configure`), enthält plattform-spezifische Firebase Optionen.

**Welche Library?** `firebase_core` / Crashlytics Initialisierung.

**SDK betroffen?** App-Runtime (Firebase init), aber Datei ist generiert.

---

## `.cursor/plans/flutter_3_migration_awaken_169f0d1e.plan.md`

**Warum geändert?** Cursor/Agent Plan-Dokumentation; kein Produktionscode.

**SDK betroffen?** Nein.

