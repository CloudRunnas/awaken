# Bug: Bestimmte MP3-Dateien spielen in Phoenix nicht ab (Scene-Rip / LAME-Anomalien)

**Status:** Offen · **Priorität:** Mittel · **Betrifft:** Android (ExoPlayer via `just_audio`)  
**Erstmals beobachtet:** 2026-07-13 · **Verifiziert mit:** Phoenix 2.4.0+14, Flutter 3.44.1

---

## Kurzbeschreibung

Manche MP3-Tracks erscheinen in der Bibliothek normal (Titel, Dauer, Cover), lassen sich antippen, aber **es startet keine Wiedergabe** — ohne sichtbare Fehlermeldung. Betroffen sind vor allem **Scene-Rips** und ältere LAME-Encodes; sauber encodierte Retail-/Streaming-Dateien funktionieren.

**Kein Package-Defekt:** `just_audio` / ExoPlayer decodieren korrekt encodierte MP3s. Ein Package-Tausch ist nicht erforderlich.

---

## Reproduktion

1. MP3 aus Scene-Release-Pipeline auf das Gerät kopieren (Beispiel unten).
2. Phoenix scannt die Datei; Dauer ≠ 0.
3. Track antippen → Player bleibt stumm / lädt ohne Audio.

### Referenzdateien (Analyse 2026-07-13, `~/Documents`)

| Datei | Ergebnis |
|-------|----------|
| `01 - HIND'S HALL 2 (feat. Anees, MC Abdul, & Amer Zahr).mp3` | Spielt |
| `10-rise_against-a_gentlemens_coup.mp3` | Spielt **nicht** |
| `10-rise_against-a_gentlemens_coup_clean.mp3` (Neu-Encode) | Spielt |

---

## Root Cause

### 1. Datei-Encoding, nicht App-Logik

Die betroffene Rise-Against-Datei ist **kein truncates/kaputtes File** im klassischen Sinn:

- GStreamer/libmpg123 decodieren vollständig bis zum Ende.
- Alle MPEG-Layer-III-Frames sind lückenlos parsebar (8.660 Frames, 0 Sync-Fehler).
- Mutagen liest ~226 s Dauer, 320 kbps CBR.

Technische Abweichungen gegenüber der funktionierenden Referenzdatei:

| Merkmal | Funktionierend (Macklemore) | Betroffen (Rise Against) |
|---------|----------------------------|---------------------------|
| LAME-Version | 3.99r, `-b 320` | **3.93**, `-b 255+` |
| Kanalmodus | Joint Stereo | Stereo |
| ID3 | Retail-Tags (~66 KB) | **Scene-Tags** (`TXXX:COMMANDS`, Ripper-`COMM`, ~111 KB) |
| Bit-Reservoir (`main_data_begin`) | 210 unique Werte | **28 unique**, ~51 % identischer Wert (463) |
| LAME-Tag in Side-Info (Frames 1–5) | nur Frame 0 | **Frames 1–5** mit `LAME3.93UUUU…` |

ExoPlayer (Android-Backend von `just_audio`) ist hier **strenger** als Desktop-Decoder und scheitert an diesem Bitstream, obwohl tolerante Decoder durchkommen.

### 2. Fehlendes Error-Handling in Phoenix

In `lib/src/beginning/utilities/audio_handlers/background.dart`:

- `setAudioSource()` ohne `try/catch`
- `playbackEventStream` ohne Prüfung auf `ProcessingState` / Player-Fehler
- Kein Fallback, wenn ExoPlayer die Quelle ablehnt

Die Meldung **„Can't play a corrupted file!“** (`corrupted_file_dialog.dart`) greift nur bei `MediaItem.duration == 0` (MediaStore/`on_audio_query`) — **nicht** bei Decode-Fehlern zur Laufzeit.

```dart
// background.dart — aktuell
_eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
  _broadcastState();
});
// …
await _audioPlayer.setAudioSource(source, preload: false, initialIndex: 0);
```

---

## Verifikation (Clean-Encode-Test)

Eine per LAME neu encodierte Version derselben Quelldatei (CBR 320 kbps, ohne Scene-ID3, LAME 3.100) **spielt in Phoenix**.

→ Ursache liegt im **Bitstream/Encode**, nicht in Pfad, URI oder fehlender Dauer.

---

## Was **nicht** hilft

| Maßnahme | Begründung |
|----------|------------|
| `just_audio` down-/upgraden | Clean-MP3 funktioniert mit aktuellem Stand (^0.10.4) |
| `Uri.file()` statt `Uri.parse()` | Betroffene Datei hat simplen ASCII-Dateinamen; funktionierende Datei hat Sonderzeichen |
| Nur `corruptedFile()`-Dialog erweitern | Betrifft nur Duration == 0, nicht ExoPlayer-Decode |

---

## Empfohlene Lösung (ohne Änderung der Original-Tracks)

Ziel: Nutzer müssen ihre Musikbibliothek **nicht manuell re-encodieren**. Originaldateien auf dem Gerät bleiben unverändert.

### Stufe 1 — Error-Handling & Transparenz (geringer Aufwand)

**Dateien:** `background.dart`, neuer Dialog z. B. `unsupported_audio_dialog.dart`

1. `playbackEventStream` auf Fehler/`idle` nach fehlgeschlagenem Load prüfen.
2. `setAudioSource` / `play` in `try/catch` ( `PlayerException` ).
3. Nutzer sichtbar informieren: *„Dieses Format konnte nicht abgespielt werden.“*
4. Optional: Pfad/Dateiname an **Firebase Crashlytics** loggen (nicht-fatal) für Häufigkeitsanalyse.

**Nutzen:** Kein stilles Versagen; klare Diagnose. **Kein** automatisches Abspielen.

### Stufe 2 — On-Demand-Transcode in App-Cache (empfohlen, mittlerer Aufwand)

Phoenix enthält bereits **`ffmpeg_kit_flutter_new`** (genutzt in `set_ringtone.dart`). Derselbe Stack kann für transparentes Fallback dienen:

```
Abspielen angefordert
    → ExoPlayer (just_audio) versucht Original-Pfad
    → bei Fehler: FFmpeg transcodiert nach App-Cache
         ${cacheDir}/playback/{hash}.mp3
    → just_audio spielt Cache-Datei
    → Original auf Gerät unverändert
```

**Beispiel-Befehl (Cache, Metadaten optional strip):**

```bash
ffmpeg -y -i "<original>" -map_metadata -1 -codec:a libmp3lame -b:a 320k "<cache>"
```

**Implementierungshinweise:**

| Thema | Vorschlag |
|-------|-----------|
| Cache-Key | SHA-256 des absoluten Dateipfads + `mtime`/Größe |
| Cache-Invalidierung | Bei geänderter Quelldatei neu transcodieren |
| UI während Transcode | Kurzer Hinweis / Ladeindikator („Track wird vorbereitet…“) |
| Speicher | Cache-Limit (z. B. LRU, max. 500 MB) in Einstellungen |
| Erstes Abspielen | ~5–15 s Verzögerung je nach Tracklänge und Gerät |
| Wiederholtes Abspielen | Sofort aus Cache |

**Vorteil:** Keine Nutzeraktion, **keine Änderung** der Original-MP3s in `/Music` o. ä.

### Stufe 3 — Native ExoPlayer-Tuning (optional, geringe Erwartung)

ExoPlayer bietet Flags für MP3-Seeking (`DefaultExtractorsFactory.setConstantBitrateSeekingEnabled`, `Mp3Extractor.FLAG_ENABLE_INDEX_SEEKING`). Diese betreffen vor allem **Seeking/Dauer**, nicht zuverlässig **Decode-Fehler** bei degenerierten Scene-Encodes. Nur prüfen, wenn Stufe 2 zu aufwändig erscheint — erwarteter Erfolg gering.

---

## Alternative (bewusst nicht empfohlen als Primärlösung)

**Manuelles Re-Encode der Bibliothek** (ffmpeg batch) behebt das Problem zuverlässig, erfordert aber Nutzeraufwand, doppelten Speicher und ersetzt Originalqualität/Tags. Sinnvoll höchstens als optionales Wartungs-Tool in den Einstellungen („Bibliothek optimieren“), nicht als Pflicht.

---

## Betroffene Code-Stellen

| Datei | Rolle |
|-------|--------|
| `lib/src/beginning/utilities/audio_handlers/background.dart` | Wiedergabe, Queue, fehlendes Error-Handling |
| `lib/src/beginning/utilities/init.dart` | `MediaItem.id = songList[i].data` (Dateipfad) |
| `lib/src/beginning/widgets/dialogues/corrupted_file_dialog.dart` | Nur Duration-==0-Pfad |
| `lib/src/beginning/utilities/set_ringtone.dart` | Vorhandenes FFmpegKit-Muster für Stufe 2 |

---

## Akzeptanzkriterien (Fix)

- [ ] Scene-Rip-Beispiel `10-rise_against-a_gentlemens_coup.mp3` spielt ab (Original unverändert).
- [ ] Saubere Referenz-MP3s spielen weiterhin ohne Transcode.
- [ ] Bei nicht behebbarem Fehler erscheint eine sichtbare Meldung (kein stilles Versagen).
- [ ] Optional: Crashlytics-Event für fehlgeschlagene Decode-Versuche.

---

## Referenzen

- [ExoPlayer Issue #1376 — MP3 Info-Header / VBR-Mismatch](https://github.com/androidx/media/issues/1376)
- [ExoPlayer Issue #878 — CBR mit Info-Header, Seeking](https://github.com/androidx/media/issues/878)
- Projekt: `docs/migration_just_audio.md`, `docs/migration_ffmpeg_kit_flutter_new.md`
