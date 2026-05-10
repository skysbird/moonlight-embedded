#!/usr/bin/env bash
# Push a built RG Cube XX package to a connected muOS device via adb.
#
# Usage:
#   scripts/install-rgcubexx-adb.sh <package-dir>
#
# <package-dir> is a directory produced by scripts/package-rgcubexx.sh,
# OR any directory that contains: moonlight.bin moonlight launch.sh
# libmoonlight-common.so.4 libgamestream.so.4 install.sh
#
# Requires: adb on PATH (env override: ADB=/path/to/adb)
set -euo pipefail

PKG_DIR="${1:-}"
if [ -z "$PKG_DIR" ]; then
  echo "usage: $0 <package-dir>" >&2
  exit 2
fi
if [ ! -d "$PKG_DIR" ]; then
  echo "[error] package dir not found: $PKG_DIR" >&2
  exit 1
fi

ADB="${ADB:-adb}"
DEST="/opt/muos/share/application/Moonlight/moonlight"
STAGE="/tmp/moonlight-rgcubexx-stage"

# MSYS path-mangling guard for Git Bash on Windows.
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL='*'

echo "[info] device check..."
"$ADB" devices

echo "[info] preparing $STAGE on device..."
"$ADB" shell "rm -rf $STAGE && mkdir -p $STAGE"

for f in moonlight.bin moonlight launch.sh libmoonlight-common.so.4 libgamestream.so.4 install.sh; do
  if [ ! -f "$PKG_DIR/$f" ]; then
    echo "[error] missing file in package: $f" >&2
    exit 1
  fi
  echo "[push] $f"
  "$ADB" push "$PKG_DIR/$f" "$STAGE/$f" >/dev/null
done

echo "[info] running installer on device..."
"$ADB" shell "chmod +x $STAGE/install.sh && sh $STAGE/install.sh"

echo "[info] cleanup stage..."
"$ADB" shell "rm -rf $STAGE"

echo "[done] verify by running: $ADB shell '$DEST/moonlight list <host>'"
