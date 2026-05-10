#!/usr/bin/env bash
# Build a self-contained release package for RG Cube XX (muOS).
#
# Inputs (all required):
#   --binary <path>       Path to the moonlight ELF (will be installed as moonlight.bin)
#   --common <path>       Path to libmoonlight-common.so.4 matching the binary's ABI
#   --gamestream <path>   Path to libgamestream.so.4 matching the binary's ABI
#   --version <ver>       Version tag, e.g. 2.7.1-muos.1
#
# Output:
#   release/moonlight-rgcubexx-<version>/    (staged dir)
#   release/moonlight-rgcubexx-<version>.zip
#
# The packaging/ template files (wrapper, launch.sh, install.sh, README.txt)
# are bundled automatically — they live in the repo, not in build inputs.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN=""
COMMON=""
GAMESTREAM=""
VERSION=""

while [ $# -gt 0 ]; do
  case "$1" in
    --binary)     BIN="$2"; shift 2 ;;
    --common)     COMMON="$2"; shift 2 ;;
    --gamestream) GAMESTREAM="$2"; shift 2 ;;
    --version)    VERSION="$2"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

for v in BIN COMMON GAMESTREAM VERSION; do
  if [ -z "${!v}" ]; then
    echo "[error] missing --$(echo "$v" | tr '[:upper:]' '[:lower:]')" >&2
    exit 2
  fi
done
for f in "$BIN" "$COMMON" "$GAMESTREAM"; do
  [ -f "$f" ] || { echo "[error] not a file: $f" >&2; exit 1; }
done

NAME="moonlight-rgcubexx-${VERSION}"
OUT_DIR="$REPO_ROOT/release/$NAME"
ZIP_PATH="$REPO_ROOT/release/${NAME}.zip"

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*

install -m 0755 "$BIN"        "$OUT_DIR/moonlight.bin"
install -m 0644 "$COMMON"     "$OUT_DIR/libmoonlight-common.so.4"
install -m 0644 "$GAMESTREAM" "$OUT_DIR/libgamestream.so.4"
install -m 0755 "$REPO_ROOT/packaging/moonlight-wrapper.sh" "$OUT_DIR/moonlight"
install -m 0755 "$REPO_ROOT/packaging/launch.sh"            "$OUT_DIR/launch.sh"
install -m 0755 "$REPO_ROOT/packaging/install.sh"           "$OUT_DIR/install.sh"
install -m 0644 "$REPO_ROOT/packaging/README.txt"           "$OUT_DIR/README.txt"

# Write a tiny manifest so a user can verify what's inside.
{
  echo "package=$NAME"
  echo "version=$VERSION"
  echo "built=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "sha256:"
  ( cd "$OUT_DIR" && for f in moonlight moonlight.bin libmoonlight-common.so.4 libgamestream.so.4 launch.sh install.sh README.txt; do
      printf "  %s  %s\n" "$(sha256sum "$f" | cut -d' ' -f1)" "$f"
    done )
} > "$OUT_DIR/MANIFEST"

# Zip it.
rm -f "$ZIP_PATH"
( cd "$REPO_ROOT/release" && zip -qr "${NAME}.zip" "$NAME" )

echo "[done] $ZIP_PATH"
ls -la "$OUT_DIR"
