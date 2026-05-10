Moonlight Embedded — RG Cube XX (muOS) build
=============================================

Target:   Anbernic RG Cube XX, Rockchip RK3566 (Cortex-A55), aarch64
muOS:     2601.0 (JACARANDA) and compatible
Upstream: moonlight-embedded 2.7.1

Contents
--------
  moonlight                    Wrapper script (sets LD_LIBRARY_PATH, execs .bin)
  moonlight.bin                Real ELF binary (FFmpeg 4.4.2 statically linked)
  libmoonlight-common.so.4     Bundled 2.7.1 ABI common lib (REQUIRED)
  libgamestream.so.4           Bundled gamestream lib
  launch.sh                    Optional standalone launcher
  install.sh                   On-device installer (drops files into the muOS app dir)
  README.txt                   This file

Why the wrapper?
----------------
muOS preinstalls /usr/lib/libmoonlight-common.so.4 -> 2.7.0 (180 KB, old ABI).
This package bundles the matching 2.7.1 lib (233 KB).  The wrapper forces
the bundled copy to be loaded first by prepending its directory to
LD_LIBRARY_PATH.  Without it the system copy wins via mux_launch.sh, struct
layouts mismatch, and every video frame fails to decode (black screen).

Install on device
-----------------
1. Copy the package to the device, e.g. via adb push or USB:
     adb push moonlight-rgcubexx-vX.Y.Z/ /tmp/moonlight-pkg/
2. Run the installer ON the device:
     adb shell sh /tmp/moonlight-pkg/install.sh
   It drops files into:
     /opt/muos/share/application/Moonlight/moonlight/
   and backs up the existing binary as moonlight.prev.<timestamp>.

Launch
------
From the muOS Apps menu — pick "Moonlight" as usual.  No env tweaks needed.

For a manual run from adb shell:
  cd /opt/muos/share/application/Moonlight/moonlight
  ./moonlight list 192.168.x.x

Roll back
---------
  cp /opt/muos/share/application/Moonlight/moonlight/moonlight.prev.* \
     /opt/muos/share/application/Moonlight/moonlight/moonlight.bin
