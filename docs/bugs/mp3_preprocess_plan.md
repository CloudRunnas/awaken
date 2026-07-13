# Plan: Automatisches MP3-Preprocessing in Phoenix (ohne Originaldateien zu verändern)

**Ziel:** Problematische MP3-Dateien (z. B. Scene-Rips / „Stereo“-Bitstream-Variante) sollen **automatisch vor dem Abspielen** so vorbereitet werden, dass ExoPlayer/`just_audio` sie zuverlässig abspielt — **ohne** dass Dateien im Musikordner des Nutzers verändert werden.

**Ausgangslage (verifiziert):**

- Originaldatei spielt nicht.
- `reencode_stereo_320k` spielt nicht.
- `reencode_joint_stereo_320k` spielt.
- `reencode_no_xing_320k` spielt.
- ID3-Manipulation ohne Bitstream-Änderung hilft nicht → **Bitstream** ist der Trigger.

---

## Minimal-Design (einfach, robust): „Transcode-on-demand in App-Cache“

### Prinzip

1. Nutzer tippt Track → Phoenix versucht **normal** (Originalpfad).
2. Wenn Playback-Start fehlschlägt (Decoder-Fehler/Abbruch), startet Phoenix **einmalig** einen FFmpeg-Transcode in den App-Cache.
3. Nach erfolgreichem Transcode spielt Phoenix **die Cache-Datei** (nicht das Original).
4. Original bleibt unverändert.

### Warum das minimal ist

- Keine neuen Dependencies: `ffmpeg_kit_flutter_new` ist bereits im Projekt (z. B. `set_ringtone.dart`).
- Keine Medienbibliothek/MediaStore-Änderungen.
- Kein „Mass-Preprocessing“: nur für tatsächlich problematische Tracks.

---

## Trigger-Logik (wann preprocessen?)

### Variante A (am einfachsten): Fallback nur bei Fehler

- Versuche `AudioSource.uri(originalUri)` wie heute.
- Wenn `setAudioSource` oder `play` eine Exception wirft **oder** ExoPlayer in einen Fehlerzustand geht:
  - Preprocessing starten
  - Danach Cache-Source abspielen

### Fehlerdetektion (praktisch)

In Phoenix wird aktuell nur `playbackEventStream` konsumiert, aber Fehler nicht ausgewertet.

**Plan:**
- `setAudioSource`/`play` in `try/catch` (u. a. `PlayerException`).
- Zusätzlich den Playback-State beobachten:
  - „idle nach load“ + kein `ready` innerhalb Timeout (z. B. 2–5 s) → als Fehlstart behandeln.

> Ziel ist nicht „perfekte“ Erkennung, sondern ein zuverlässiger UX-Fallback.

---

## Transcode-Parameter (entscheidend!)

Da „Stereo“-Bitstream-Variante bei dir scheitert, muss der Cache-Transcode **bewusst** eine funktionierende Variante erzeugen.

### Empfohlener FFmpeg-Befehl (Cache-Ausgabe)

**Joint Stereo (minimal, ohne zusätzliche „Aufräum“-Schritte):**

```bash
ffmpeg -y -i "<original>" \
  -codec:a libmp3lame -b:a 320k -joint_stereo 1 \
  "<cache>.mp3"
```

**Begründung:**
- `-joint_stereo 1`: erzeugt die Variante, die bei dir spielt.
- Keine weiteren Parameter (kein `-write_xing 0`, kein `-map_metadata -1`): Phoenix macht **nur** das Nötigste, um Abspielbarkeit herzustellen.

### Optional (fallback 2)

Wenn Transcode (MP3) fehlschlägt:
- Alternative Cache als AAC (m4a) mit `-c:a aac -b:a 256k`
- aber nur, wenn `just_audio`/ExoPlayer m4a zuverlässig kann (meist ja).

---

## Cache-Strategie (klein, simpel, sicher)

### Cache-Pfad

- `getTemporaryDirectory()` oder `getApplicationSupportDirectory()`
- z. B. `${cacheDir}/preprocessed_audio/`

### Cache-Key

Minimal (ohne Hashing-Lib):
- `<songIdOrPathHash>_<mtime>_<size>.mp3`

Beispiel:
- `sha1(path)` wäre besser, aber selbst `base64Url(path)` geht, solange gekürzt/gesäubert.

### Cache-Invalidierung

Sehr einfach:
- Wenn die Originaldatei `mtime` oder `size` anders ist → neu transcodieren.

### Cache-Limit

Einfacher LRU-Mechanismus:
- max. z. B. 500 MB oder 200 Dateien
- beim Start oder beim Hinzufügen: älteste (nach atime/mtime der Cache-Datei) löschen

---

## UX (möglichst simpel)

- Beim ersten Fallback:
  - kurzer Hinweis „Track wird vorbereitet…“ (Snack/Flushbar)
  - optional Fortschritt, aber nicht nötig: lieber Spinner/Timeout
- Bei dauerhaftem Scheitern:
  - klare Meldung: „Dieser Track kann nicht abgespielt werden.“

---

## Integration in Phoenix (konkret, kleinster Scope)

### Wo einbauen?

`lib/src/beginning/utilities/audio_handlers/background.dart`

Heute:
- `updateQueue()` baut `ConcatenatingAudioSource` aus `MediaItem.id` (Dateipfad)
- `setAudioSource(... preload: false ...)`

**Plan-Änderung (minimal):**

1. Beim Erstellen der Source für ein Item:
   - `originalPath = mediaItem.id`
   - `effectivePath = await maybePreprocess(originalPath)`
   - `AudioSource.uri(Uri.file(effectivePath))`
2. `maybePreprocess()`:
   - prüft Cache-Existenz und Validität
   - wenn keine Cache-Datei: erst Original versuchen, bei Fehler transcodieren

> Alternative (noch weniger invasive): Erst Original spielen wie heute. Nur wenn Playback-Start fehlschlägt, dann `setAudioSource` auf Cache-Datei setzen und erneut `play()` ausführen.

---

## Sicherheits-/Performance-Notizen

- Transcode ist CPU-intensiv → nur on-demand.
- Cache-Dateien müssen gelöscht werden (Limit/Settings).
- Originaldateien werden nur gelesen (keine Schreibzugriffe außerhalb App-Cache).

---

## Akzeptanzkriterien

- [ ] Original (problematisch) spielt nach Fallback ab, ohne dass im Musikordner Dateien verändert werden.
- [ ] Saubere MP3s spielen ohne Transcode.
- [ ] `reencode_stereo_320k`-Äquivalent wird vermieden (Joint Stereo erzwingen).
- [ ] Bei Scheitern klare Fehlermeldung (kein stilles Versagen).

