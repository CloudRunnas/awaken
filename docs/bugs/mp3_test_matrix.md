# MP3-Testmatrix — Rise Against / Scene-Rip

Isolierte Testdateien zur Einordnung, **welches Attribut** das Phoenix-Abspielfproblem auslöst.

**Quelle:** `10-rise_against-a_gentlemens_coup.mp3` (Original, spielt nicht)  
**Erzeugt mit:** `scripts/generate_mp3_test_matrix.sh`  
**Ablage (lokal):** `~/Documents/10-rise_against-a_gentlemens_coup_test_*.mp3`

---

## Test-Anleitung

1. Alle `*_test_*.mp3` auf das Gerät kopieren.
2. Phoenix-Bibliothek neu scannen (oder Dateien in Musikordner legen).
3. Jede Datei einmal abspielen und Ergebnis notieren (spielt / spielt nicht).
4. Ergebnisse mit Tabelle unten vergleichen.

---

## Testdateien

### Gruppe A — nur ID3/Metadaten geändert (Audio-Bitstream **identisch**)

| Datei | Geändertes Attribut | Erwartung |
|-------|---------------------|-----------|
| `…_test_01_id3stripped_cbr.mp3` | Alle ID3-Tags entfernt | Prüft: Metadaten generell |
| `…_test_02_id3_no_scene.mp3` | Scene-Tags entfernt (`TXXX:COMMANDS`, Ripper-`COMM`, …) | Prüft: Scene-Metadaten |
| `…_test_03_id3_no_apic.mp3` | Nur Cover (`APIC`) entfernt | Prüft: großes Embedded-Artwork |
| `…_test_04_id3_no_uslt.mp3` | Nur Lyrics (`USLT`) entfernt | Prüft: Lyrics-Frame |
| `…_test_05_id3_no_comm.mp3` | Alle `COMM`-Frames entfernt | Prüft: Comment-Frames |
| `…_test_06_id3_minimal_retail.mp3` | Nur Retail-Basis-Tags (TIT2, TPE1, TALB, …), kein APIC/Scene | Prüft: „Retail-ähnliche“ Tags |
| `…_test_07_id3_no_id3v1.mp3` | Nur ID3v1-Footer (128 B am Ende) entfernt | Prüft: ID3v1 |

**Interpretation Gruppe A:** Spielt **keine** Datei → Ursache liegt im **Audio-Bitstream**, nicht in ID3.

---

### Gruppe B — Re-Encode (neuer Bitstream / LAME)

| Datei | Geändertes Attribut | Erwartung |
|-------|---------------------|-----------|
| `…_test_08_reencode_320k_cbr.mp3` | Neu encodiert CBR 320k (LAME 3.100), keine Metadaten | Referenz-Clean (soll spielen) |
| `…_test_09_reencode_joint_stereo_320k.mp3` | Wie 08, aber **Joint Stereo** | Prüft: Kanalmodus (Original: Stereo) |
| `…_test_10_reencode_stereo_320k.mp3` | Wie 08, explizit **Stereo** | Joint vs. Stereo bei Clean-Encode |
| `…_test_11_reencode_no_xing_320k.mp3` | CBR 320k **ohne** Info/Xing-Header | Prüft: Info-TOC-Header |
| `…_test_12_reencode_vbr_q2.mp3` | VBR Qualität q=2 (~208 kbps) | Prüft: `-b 255+`/VBR-Stil |
| `…_test_13_reencode_cbr_256k.mp3` | CBR 256 kbps | Prüft: niedrigere Ziel-Bitrate |

**Interpretation Gruppe B:** Mindestens 08 spielt → Re-Encode behebt Bitstream-Problem.

---

## Zuordnung zu Bug-Attributen

| Attribut (Bug-Bericht) | Isoliert durch |
|------------------------|----------------|
| Scene-ID3 / Ripper-Tags | `test_02`, `test_06` |
| Großes APIC (~108 KB) | `test_03` |
| Alle Metadaten | `test_01` |
| LAME 3.93 / Bit-Reservoir / Side-Info-LAME-Tag | `test_08`–`13` (nur per Re-Encode änderbar) |
| Kanalmodus Stereo vs. Joint Stereo | `test_09` vs. `test_10` |
| Info/Xing-Header + TOC | `test_11` vs. `test_08` |
| Encoder `-b 255+` / VBR-Charakter | `test_12`, `test_13` |

---

## Erneut erzeugen

```bash
./scripts/generate_mp3_test_matrix.sh
# oder mit anderer Quelle:
./scripts/generate_mp3_test_matrix.sh /pfad/zum/original.mp3
```

Voraussetzung: Static-ffmpeg unter `/tmp/ffmpeg-7.0.2-amd64-static/ffmpeg` (oder `FFMPEG=…` setzen).

---

Siehe auch: [mp3_scene_rip_playback_failure.md](mp3_scene_rip_playback_failure.md)
