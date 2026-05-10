#!/bin/sh
# On-device installer for Moonlight RG Cube XX build.
# Run this ON the muOS device (adb shell sh /path/to/install.sh).
set -e

DEST="/opt/muos/share/application/Moonlight/moonlight"
SRC="$(dirname "$(readlink -f "$0")")"
TS="$(date +%s 2>/dev/null || echo manual)"

if [ ! -d "$DEST" ]; then
  echo "[error] $DEST does not exist — is Moonlight installed on this muOS?" >&2
  exit 1
fi

echo "[info] installing from $SRC to $DEST"

# Back up whatever currently sits at moonlight (binary OR wrapper).
if [ -e "$DEST/moonlight" ]; then
  cp "$DEST/moonlight" "$DEST/moonlight.prev.$TS"
  echo "[info] backed up current entrypoint -> moonlight.prev.$TS"
fi
if [ -e "$DEST/moonlight.bin" ]; then
  cp "$DEST/moonlight.bin" "$DEST/moonlight.bin.prev.$TS"
fi

install -m 0755 "$SRC/moonlight.bin"             "$DEST/moonlight.bin"
install -m 0755 "$SRC/moonlight"                 "$DEST/moonlight"
install -m 0644 "$SRC/libmoonlight-common.so.4"  "$DEST/libmoonlight-common.so.4"
install -m 0644 "$SRC/libgamestream.so.4"        "$DEST/libgamestream.so.4"
install -m 0755 "$SRC/launch.sh"                 "$DEST/launch.sh"

echo "[info] sanity check:"
ls -la "$DEST/moonlight" "$DEST/moonlight.bin"

# Quick smoke test — should print version then exit non-zero on usage.
"$DEST/moonlight" 2>&1 | head -1 || true

echo "[done] open Moonlight from the muOS Apps menu."
