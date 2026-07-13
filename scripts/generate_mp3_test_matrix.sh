#!/usr/bin/env bash
# Erzeugt isolierte Test-MP3s für mp3_scene_rip_playback_failure (Rise Against).
# Ausgabe: ~/Documents/10-rise_against-a_gentlemens_coup_test_*.mp3

set -euo pipefail

SRC="${1:-$HOME/Documents/10-rise_against-a_gentlemens_coup.mp3}"
DOC="$(dirname "$SRC")"
FF="${FFMPEG:-/tmp/ffmpeg-7.0.2-amd64-static/ffmpeg}"
VENV="${MP3VENV:-/tmp/mp3venv}"

if [[ ! -f "$SRC" ]]; then
  echo "Quelle nicht gefunden: $SRC" >&2
  exit 1
fi
if [[ ! -x "$FF" ]]; then
  echo "ffmpeg nicht gefunden: $FF" >&2
  exit 1
fi
if [[ ! -x "$VENV/bin/python3" ]]; then
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install -q mutagen
fi

BASE="$DOC/10-rise_against-a_gentlemens_coup_test"

copy_id3_edit() {
  local suffix="$1"
  shift
  "$VENV/bin/python3" - "$SRC" "${BASE}_${suffix}.mp3" "$@" <<'PY'
import shutil, sys
from mutagen.id3 import ID3
from mutagen.mp3 import MP3

src, dst = sys.argv[1], sys.argv[2]
ops = sys.argv[3:]

shutil.copy2(src, dst)
try:
    tags = ID3(dst)
except Exception:
    print(f"WARN: keine ID3 in {dst}", file=sys.stderr)
    sys.exit(0)

for op in ops:
    if op == "clear_all":
        tags.clear()
    elif op == "del_apic":
        for k in list(tags.keys()):
            if k.startswith("APIC"):
                del tags[k]
    elif op == "del_uslt":
        for k in list(tags.keys()):
            if k.startswith("USLT"):
                del tags[k]
    elif op == "del_comm":
        for k in list(tags.keys()):
            if k.startswith("COMM"):
                del tags[k]
    elif op == "del_scene":
        for k in list(tags.keys()):
            if k.startswith("TXXX") and k in ("TXXX:COMMANDS", "TXXX:COVERART", "TXXX:ALBUMARTIST"):
                del tags[k]
            if k.startswith("COMM"):
                del tags[k]
    elif op == "minimal_retail":
        keep = {"TIT2", "TPE1", "TALB", "TRCK", "TDRC", "TCON"}
        for k in list(tags.keys()):
            frame_id = k.split(":", 1)[0]
            if frame_id not in keep:
                del tags[k]
    elif op == "no_v1":
        pass
    else:
        print(f"Unbekannte Operation: {op}", file=sys.stderr)
        sys.exit(1)

if "clear_all" in ops:
    audio = MP3(dst)
    audio.delete()
    audio.save(v1=0)
elif "no_v1" in ops:
    tags.save(v1=0)
else:
    tags.save()
PY
}

reencode() {
  local suffix="$1"
  shift
  "$FF" -y -hide_banner -loglevel error -i "$SRC" -map_metadata -1 -codec:a libmp3lame "$@" \
    "${BASE}_${suffix}.mp3"
}

echo "Quelle: $SRC"
echo "Ziel:   ${BASE}_*.mp3"
echo

# --- ID3 / Metadaten (Audio-Bitstream unverändert) ---
copy_id3_edit "01_id3stripped_cbr" clear_all
copy_id3_edit "02_id3_no_scene" del_scene
copy_id3_edit "03_id3_no_apic" del_apic
copy_id3_edit "04_id3_no_uslt" del_uslt
copy_id3_edit "05_id3_no_comm" del_comm
copy_id3_edit "06_id3_minimal_retail" minimal_retail
copy_id3_edit "07_id3_no_id3v1" no_v1

# --- Re-Encode (neuer Bitstream / Encoder) ---
reencode "08_reencode_320k_cbr" -b:a 320k
reencode "09_reencode_joint_stereo_320k" -b:a 320k -joint_stereo 1
reencode "10_reencode_stereo_320k" -b:a 320k -joint_stereo 0
reencode "11_reencode_no_xing_320k" -b:a 320k -write_xing 0
reencode "12_reencode_vbr_q2" -q:a 2
reencode "13_reencode_cbr_256k" -b:a 256k

echo
echo "Fertig. $(ls -1 "${BASE}"_*.mp3 2>/dev/null | wc -l) Testdateien in $DOC"
