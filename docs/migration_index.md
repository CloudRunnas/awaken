# Flutter 3 Migration — Dokumentationsindex

> **Fortsetzung der Migration:** Siehe [migration_status.md](migration_status.md) für aktuellen Stand, offene Aufgaben und Handoff-Anleitung.

Baseline: `3ff5975` (Flutter 2) · Ziel: Dart 3 / Flutter 3.44

Dieses Index listet alle Migrations-Dokumente und ordnet **jeden Git-Diff-Hunk** (`git diff 3ff5975`) genau einem Dokument zu.

## Übersicht aller Migrations-Dokumente

| Dokument | Paket / Bereich | Alt → Neu |
|----------|-----------------|-----------|
| [migration_sdk_dart.md](migration_sdk_dart.md) | Dart/Flutter SDK | `>=2.12.0 <3.0.0` → `>=3.5.0 <4.0.0` |
| [migration_sdk_android.md](migration_sdk_android.md) | Android Gradle/Build | Groovy AGP 7 → Kotlin-DSL AGP 8 |
| [migration_integration_test.md](migration_integration_test.md) | integration_test (dev) | — → SDK |
| [migration_flutter_lints.md](migration_flutter_lints.md) | flutter_lints | ^2.0.1 → ^5.0.0 |
| [migration_another_flushbar.md](migration_another_flushbar.md) | another_flushbar | ^1.10.29 → ^1.12.30 |
| [migration_another_xlider.md](migration_another_xlider.md) | another_xlider | ^1.1.2 (unverändert) |
| [migration_page_transition.md](migration_page_transition.md) | page_transition | ^2.0.9 → ^2.2.1 |
| [migration_palette_generator.md](migration_palette_generator.md) | palette_generator | ^0.3.3+1 → ^0.3.3+5 |
| [migration_sleek_circular_slider.md](migration_sleek_circular_slider.md) | sleek_circular_slider | ^2.0.1 → ^2.1.0 |
| [migration_audio_service.md](migration_audio_service.md) | audio_service | ^0.18.7 → ^0.18.17 |
| [migration_ffmpeg_kit_flutter_new.md](migration_ffmpeg_kit_flutter_new.md) | ffmpeg_kit_flutter_new | flutter_ffmpeg ^0.4.2 → ^2.0.0 |
| [migration_just_audio.md](migration_just_audio.md) | just_audio | ^0.9.28 → ^0.10.4 |
| [migration_on_audio_query.md](migration_on_audio_query.md) | on_audio_query | 2.6.1 → ^2.9.0 |
| [migration_on_audio_edit.md](migration_on_audio_edit.md) | on_audio_edit | ^1.4.0+1 (CI-Patch für 1.5.1 Kotlin) |
| [migration_device_info_plus.md](migration_device_info_plus.md) | device_info_plus | device_info ^2.0.3 → ^11.3.0 |
| [migration_image_picker.md](migration_image_picker.md) | image_picker | ^0.8.5+3 → ^1.1.2 |
| [migration_path_provider.md](migration_path_provider.md) | path_provider | ^2.0.11 → ^2.1.5 |
| [migration_permission_handler.md](migration_permission_handler.md) | permission_handler | ^10.0.0 → ^11.4.0 |
| [migration_provider.md](migration_provider.md) | provider | ^6.0.3 → ^6.1.4 |
| [migration_share_plus.md](migration_share_plus.md) | share_plus | ^4.0.10+1 → ^10.1.4 |
| [migration_flutter_displaymode.md](migration_flutter_displaymode.md) | flutter_displaymode | ^0.4.0 → ^0.6.0 |
| [migration_cupertino_icons.md](migration_cupertino_icons.md) | cupertino_icons | ^1.0.5 → ^1.0.8 |
| [migration_flutter_launcher_icons.md](migration_flutter_launcher_icons.md) | flutter_launcher_icons | ^0.10.0 → ^0.14.3 |
| [migration_ionicons.md](migration_ionicons.md) | ionicons | ^0.2.1 → ^0.2.2 |
| [migration_material_design_icons_flutter.md](migration_material_design_icons_flutter.md) | material_design_icons_flutter | ^5.0.6996 → ^7.0.7296 |
| [migration_http.md](migration_http.md) | http | ^0.13.5 → ^1.4.0 |
| [migration_html.md](migration_html.md) | html | ^0.15.0 → ^0.15.5 |
| [migration_url_launcher.md](migration_url_launcher.md) | url_launcher | ^6.1.5 → ^6.3.1 |
| [migration_awesome_notifications.md](migration_awesome_notifications.md) | awesome_notifications | ^0.6.21 → ^0.10.1 |
| [migration_screenshot.md](migration_screenshot.md) | screenshot | ^1.2.3 → ^3.0.0 |

## Hunk-Zuordnung (`git diff 3ff5975`)

### `pubspec.yaml`

| Hunk (Inhalt) | Dokument |
|---------------|----------|
| `environment: sdk` Constraint | [migration_sdk_dart.md](migration_sdk_dart.md) |
| `another_flushbar` Version | [migration_another_flushbar.md](migration_another_flushbar.md) |
| `page_transition` Version | [migration_page_transition.md](migration_page_transition.md) |
| `palette_generator` Version | [migration_palette_generator.md](migration_palette_generator.md) |
| `sleek_circular_slider` Version | [migration_sleek_circular_slider.md](migration_sleek_circular_slider.md) |
| `audio_service` Version | [migration_audio_service.md](migration_audio_service.md) |
| `flutter_ffmpeg` → `ffmpeg_kit_flutter_new` | [migration_ffmpeg_kit_flutter_new.md](migration_ffmpeg_kit_flutter_new.md) |
| `just_audio` Version | [migration_just_audio.md](migration_just_audio.md) |
| `on_audio_query` Version | [migration_on_audio_query.md](migration_on_audio_query.md) |
| `device_info` → `device_info_plus` | [migration_device_info_plus.md](migration_device_info_plus.md) |
| `image_picker` Version | [migration_image_picker.md](migration_image_picker.md) |
| `path_provider` Version | [migration_path_provider.md](migration_path_provider.md) |
| `permission_handler` Version | [migration_permission_handler.md](migration_permission_handler.md) |
| `provider` Version | [migration_provider.md](migration_provider.md) |
| `share_plus` Version | [migration_share_plus.md](migration_share_plus.md) |
| `flutter_displaymode` Version | [migration_flutter_displaymode.md](migration_flutter_displaymode.md) |
| `cupertino_icons` Version | [migration_cupertino_icons.md](migration_cupertino_icons.md) |
| `flutter_launcher_icons` Version | [migration_flutter_launcher_icons.md](migration_flutter_launcher_icons.md) |
| `ionicons` Version | [migration_ionicons.md](migration_ionicons.md) |
| `material_design_icons_flutter` Version | [migration_material_design_icons_flutter.md](migration_material_design_icons_flutter.md) |
| `http` Version | [migration_http.md](migration_http.md) |
| `html` Version | [migration_html.md](migration_html.md) |
| `url_launcher` Version | [migration_url_launcher.md](migration_url_launcher.md) |
| `awesome_notifications` Version | [migration_awesome_notifications.md](migration_awesome_notifications.md) |
| `screenshot` Version | [migration_screenshot.md](migration_screenshot.md) |
| `integration_test` dev-Dependency (neu) | [migration_integration_test.md](migration_integration_test.md) |
| `flutter_lints` Version | [migration_flutter_lints.md](migration_flutter_lints.md) |
| `flutter:` Sektion (Kommentare/Whitespace) | *(kosmetisch — kein Migrations-Doc)* |

### `lib/`

| Datei | Hunk (Inhalt) | Dokument |
|-------|---------------|----------|
| `lib/main.dart` | Entfernung `Paint.enableDithering = true` | [migration_sdk_dart.md](migration_sdk_dart.md) |
| `lib/src/beginning/begin.dart` | `import services.dart` | [migration_sdk_dart.md](migration_sdk_dart.md) |
| `lib/src/beginning/begin.dart` | `WillPopScope` → `PopScope` | [migration_sdk_dart.md](migration_sdk_dart.md) |
| `lib/src/beginning/pages/playlist/add_songs.dart` | `const Icon(MdiIcons.…)` → `Icon(MdiIcons.…)` | [migration_material_design_icons_flutter.md](migration_material_design_icons_flutter.md) |
| `lib/src/beginning/pages/playlist/add_songs.dart` | `const Icon(Ionicons.…)` → `Icon(Ionicons.…)` | [migration_ionicons.md](migration_ionicons.md) |
| `lib/src/beginning/pages/settings/settings_pages/directories.dart` | `WillPopScope` → `PopScope` | [migration_sdk_dart.md](migration_sdk_dart.md) |
| `lib/src/beginning/pages/settings/settings_pages/phoenix.dart` | `const Icon(MdiIcons.gmail/github)` → `Icon(…)` | [migration_material_design_icons_flutter.md](migration_material_design_icons_flutter.md) |
| `lib/src/beginning/utilities/audio_handlers/background.dart` | `AudioPlayer(…)` Konstruktor vereinfacht | [migration_just_audio.md](migration_just_audio.md) |
| `lib/src/beginning/utilities/audio_handlers/previous_play_skip.dart` | Import `screenshot_ui` → `screenshot_UI` | [migration_screenshot.md](migration_screenshot.md) |
| `lib/src/beginning/utilities/constants.dart` | `useMaterial3: false` | [migration_sdk_dart.md](migration_sdk_dart.md) |
| `lib/src/beginning/utilities/constants.dart` | `MaterialStateProperty` → `WidgetStateProperty` | [migration_sdk_dart.md](migration_sdk_dart.md) |
| `lib/src/beginning/utilities/init.dart` | Import `device_info` → `device_info_plus` | [migration_device_info_plus.md](migration_device_info_plus.md) |
| `lib/src/beginning/utilities/init.dart` | `requestMusicLibraryPermission()` (neu) | [migration_permission_handler.md](migration_permission_handler.md) |
| `lib/src/beginning/utilities/init.dart` | `fetchSongs()` Permission-Check | [migration_on_audio_query.md](migration_on_audio_query.md) |
| `lib/src/beginning/utilities/set_ringtone.dart` | `flutter_ffmpeg` → `FFmpegKit` | [migration_ffmpeg_kit_flutter_new.md](migration_ffmpeg_kit_flutter_new.md) |
| `lib/src/beginning/widgets/dialogues/double_tap.dart` | `const Icon(MdiIcons.heart)` → `Icon(…)` | [migration_material_design_icons_flutter.md](migration_material_design_icons_flutter.md) |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | Import `screenshot_ui` → `screenshot_UI` | [migration_screenshot.md](migration_screenshot.md) |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | Import `init.dart` | [migration_permission_handler.md](migration_permission_handler.md) |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | `Share.shareFiles` → `Share.shareXFiles` (3×) | [migration_share_plus.md](migration_share_plus.md) |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | `Permission.storage` → `requestMusicLibraryPermission()` (3×) | [migration_permission_handler.md](migration_permission_handler.md) |
| `lib/src/beginning/widgets/dialogues/on_hold.dart` | `const Icon(MdiIcons.heart)` → `Icon(…)` | [migration_material_design_icons_flutter.md](migration_material_design_icons_flutter.md) |

### `android/`

| Datei | Hunk (Inhalt) | Dokument |
|-------|---------------|----------|
| `android/app/build.gradle` | Datei gelöscht | [migration_sdk_android.md](migration_sdk_android.md) |
| `android/build.gradle.kts` | `compileSdk` ≥ 34 für Legacy-Plugins | [migration_flutter_displaymode.md](migration_flutter_displaymode.md) |
| `android/app/build.gradle.kts` | `isMinifyEnabled = false` (R8 Play-Core) | [migration_sdk_android.md](migration_sdk_android.md) |
| `android/build.gradle` | Datei gelöscht | [migration_sdk_android.md](migration_sdk_android.md) |
| `android/build.gradle` | `flutterFFmpegPackage` entfernt | [migration_ffmpeg_kit_flutter_new.md](migration_ffmpeg_kit_flutter_new.md) |
| `android/build.gradle.kts` | Datei neu | [migration_sdk_android.md](migration_sdk_android.md) |
| `android/settings.gradle` | Datei gelöscht | [migration_sdk_android.md](migration_sdk_android.md) |
| `android/settings_aar.gradle` | Datei gelöscht | [migration_sdk_android.md](migration_sdk_android.md) |
| `android/settings.gradle.kts` | Datei neu | [migration_sdk_android.md](migration_sdk_android.md) |
| `android/gradle/wrapper/gradle-wrapper.properties` | Gradle 7.3.3 → 8.11.1 | [migration_sdk_android.md](migration_sdk_android.md) |
| `android/app/src/main/AndroidManifest.xml` | `READ_EXTERNAL_STORAGE` + `maxSdkVersion="32"` | [migration_permission_handler.md](migration_permission_handler.md) |
| `android/app/src/main/AndroidManifest.xml` | `WRITE_EXTERNAL_STORAGE` + `maxSdkVersion="32"` | [migration_permission_handler.md](migration_permission_handler.md) |
| `android/app/src/main/AndroidManifest.xml` | `READ_MEDIA_AUDIO` (neu) | [migration_permission_handler.md](migration_permission_handler.md) |
| `android/app/src/main/AndroidManifest.xml` | `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (neu) | [migration_audio_service.md](migration_audio_service.md) |
| `android/app/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS` (neu) | [migration_awesome_notifications.md](migration_awesome_notifications.md) |
| `android/app/src/main/AndroidManifest.xml` | `AudioService` + `foregroundServiceType` | [migration_audio_service.md](migration_audio_service.md) |

### `scripts/` und CI

| Datei | Hunk (Inhalt) | Dokument |
|-------|---------------|----------|
| `scripts/patch_android_namespaces.sh` | Namespace-Patch für Legacy-Plugins | [migration_sdk_android.md](migration_sdk_android.md) |
| `scripts/patch_on_audio_edit_kotlin.sh` | Kotlin-Fixes für on_audio_edit 1.5.1 | [migration_on_audio_edit.md](migration_on_audio_edit.md) |
| `scripts/patch_flutter_displaymode.sh` | compileSdk 33 → 34 in Plugin | [migration_flutter_displaymode.md](migration_flutter_displaymode.md) |
| `.github/workflows/build-apk.yml` | Flutter 3.44.1 APK-Build-Pipeline | [migration_sdk_android.md](migration_sdk_android.md) |
| `.github/workflows/build-apk.yml` | `patch_on_audio_edit_kotlin.sh` Schritt | [migration_on_audio_edit.md](migration_on_audio_edit.md) |

### Nicht zugeordnet (automatisch generiert / außerhalb Scope)

| Datei | Grund |
|-------|-------|
| `pubspec.lock` | Automatisch generiert durch `flutter pub get` |
| `.cursor/plans/flutter_3_migration_awaken_169f0d1e.plan.md` | Migrations-Plan, kein Produktionscode |

## Integrations-Tests ohne eigenes Migrations-Doc

Folgende Pakete haben Integrations-Tests, aber **keine Versionsänderung** in `pubspec.yaml` gegenüber `3ff5975`:

| Paket | Integrations-Test |
|-------|-------------------|
| animated_text_kit | `migration_animated_text_kit_test.dart` |
| flare_loading | `migration_flare_loading_test.dart` |
| flutter_remixicon | `migration_flutter_remixicon_test.dart` |
| hive_flutter | `migration_hive_flutter_test.dart` |
| html_unescape | `migration_html_unescape_test.dart` |
| `on_audio_edit` | `migration_on_audio_edit_test.dart` | [migration_on_audio_edit.md](migration_on_audio_edit.md) |
| sliding_up_panel | `migration_sliding_up_panel_test.dart` |

Diese Pakete wurden nur zur Kompatibilitätsvalidierung getestet; siehe jeweiliges Test-File.
