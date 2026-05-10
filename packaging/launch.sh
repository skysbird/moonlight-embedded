#!/bin/bash
# RG Cube XX / muOS Moonlight launcher.
#
# Note on SDL_VIDEODRIVER:
#   muOS ships a custom SDL2 build whose only video driver is "MALI"
#   (verified via `strings libSDL2-2.0.so.0 | grep _bootstrap`).  The
#   "fbcon" driver does NOT exist — setting SDL_VIDEODRIVER=fbcon
#   produced "Could not initialize SDL - fbcon not available" and a
#   black screen.  Leave SDL_VIDEODRIVER unset and SDL2 picks MALI.
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE:$LD_LIBRARY_PATH"
export SDL_AUDIODRIVER=alsa
export SDL_NOMOUSE=1
cd "$HERE"
./moonlight "$@"
