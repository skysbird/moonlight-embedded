#!/bin/sh
# Moonlight wrapper for RG Cube XX (muOS).
#
# Why this exists:
#   muOS ships an older /usr/lib/libmoonlight-common.so.4 (180 KB, 2.7.0)
#   while the binary in this package is built against the newer 2.7.1 ABI
#   (233 KB libmoonlight-common.so.4 shipped alongside).  If the loader
#   resolves the system copy first the struct layouts disagree, every
#   decoded NAL is rejected by ffmpeg with "Decode failed - Invalid
#   argument", and the user sees a black screen.
#
#   The launcher in mux_launch.sh only prepends $LOVEDIR/libs to
#   LD_LIBRARY_PATH, which does NOT include the moonlight subdir, so
#   without this wrapper the system copy wins.  This script forces the
#   bundled libs to be loaded first regardless of who invokes us.
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE:$LD_LIBRARY_PATH"
exec "$HERE/moonlight.bin" "$@"
