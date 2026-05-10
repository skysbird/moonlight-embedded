# Deployment — Moonlight on RG Cube XX (muOS)

This document covers (1) the user-visible install path, (2) the two
non-obvious bugs that prevented launch from muOS until now, and (3) how
to roll back.

## Install

Pick a release zip (see `release/`) and run, from a host with `adb`:

```
unzip moonlight-rgcubexx-2.7.1-muos.1.zip
scripts/install-rgcubexx-adb.sh moonlight-rgcubexx-2.7.1-muos.1
```

That pushes the package to `/tmp/moonlight-rgcubexx-stage/` on the
device, runs `install.sh` there, and lands the files under
`/opt/muos/share/application/Moonlight/moonlight/` with proper backups.

After install: open **Moonlight** from the muOS Apps menu — no environment
tweaks required.

### What ends up on the device

```
/opt/muos/share/application/Moonlight/moonlight/
├── moonlight                  ← shell wrapper (130 B)  ★ entrypoint
├── moonlight.bin              ← the real ELF (9.6 MB, ffmpeg 4.4.2 static)
├── libmoonlight-common.so.4   ← bundled 2.7.1 ABI common lib (233 KB)
├── libgamestream.so.4         ← matching gamestream lib
├── launch.sh                  ← optional standalone launcher
└── moonlight.prev.<ts>        ← previous version, kept by install.sh
```

The wrapper is what makes the rest work.  Read on.

## Root cause #1 — `Could not initialize SDL - fbcon not available`

**Symptom.** On launch:

```
Could not initialize SDL - fbcon not available
```

…and a black screen.

**Why.** muOS ships a custom SDL2 build whose only video bootstrap is
`MALI`:

```
$ strings /usr/lib/libSDL2-2.0.so.0 | grep _bootstrap
MALI_bootstrap
ALSA_bootstrap
```

There is no `fbcon` driver in this SDL2 (fbcon was an SDL 1.2 thing
anyway).  The original `launch.sh` shipped in the muOS Moonlight app
hard-coded `SDL_VIDEODRIVER=fbcon`, so SDL bailed out before it ever
opened the screen.

**Fix.** Don't set `SDL_VIDEODRIVER` — let SDL2 pick MALI.  The shipped
`packaging/launch.sh` does exactly this.  And for the muOS launcher
flow specifically, this is moot: `mux_launch.sh` invokes `./moonlight`
directly without touching `SDL_VIDEODRIVER`, so as long as nobody else
sets it the binary just works.

## Root cause #2 — `Decode failed - Invalid argument` (every frame)

**Symptom.** Stream connects, audio/video pipeline initialises, RTP
packets flow in (UDP `InDatagrams` climbs), then stdout floods with:

```
Decode failed - Invalid argument
Decode failed - Invalid argument
...
```

No picture.  The pipe looks alive but every NAL is rejected by ffmpeg
(`avcodec_send_packet` returns `-EINVAL`).

**Why.**  muOS preinstalls

```
/usr/lib/libmoonlight-common.so.4 -> libmoonlight-common.so.2.7.0   (180 KB, old ABI)
```

Our build produces and ships

```
libmoonlight-common.so.4                                            (233 KB, 2.7.1 ABI)
```

`mux_launch.sh` only prepends `$LOVEDIR/libs` to `LD_LIBRARY_PATH`.
That path does **not** include the moonlight subdirectory.  Result: the
loader resolves `libmoonlight-common.so.4` from `/usr/lib/`, the binary
gets a struct layout that doesn't match what it was compiled against,
the bytes it hands to ffmpeg are garbage, and every frame is rejected.

Verified empirically:

| `LD_LIBRARY_PATH` includes the moonlight dir | Decode-failed lines / 12 s |
|---|---|
| no  (system 180 KB lib loads)  | 244 |
| yes (bundled 233 KB lib loads) | **0** |

**Fix.**  A wrapper script named `moonlight` that prepends its own
directory and execs the renamed `moonlight.bin`.  The actual change is
two lines:

```sh
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE:$LD_LIBRARY_PATH"
exec "$HERE/moonlight.bin" "$@"
```

This works regardless of who invokes us — `mux_launch.sh`'s
`eval "./moonlight $COMMAND"`, or `launch.sh`, or a manual `adb shell`.
We don't need to patch any muOS-owned files.

The wrapper template lives at `packaging/moonlight-wrapper.sh` and is
copied into every release zip as `moonlight`.

## Verification

After install, from `adb shell`:

```
cd /opt/muos/share/application/Moonlight/moonlight
./moonlight list <host-ip>
```

Expected: app list (e.g. "1. Steam Big Picture\n2. Desktop").  Then a
quick stream smoke-test:

```
./moonlight stream <host-ip> -app "Desktop"
```

Screen on the device should switch to the host desktop.  Hit
`Ctrl+Alt+Shift+Q` (or `Play+Back+L+R`) to quit.

## Roll back

`install.sh` always saves the previous binary to
`moonlight.prev.<timestamp>`.  Restore with:

```
adb shell '
  cd /opt/muos/share/application/Moonlight/moonlight
  ls moonlight.prev.* | sort | tail -1 | xargs -I{} cp {} moonlight.bin
  rm -f moonlight   # if you also want to drop the wrapper
'
```

(The original muOS binary is monolithic — there's no separate
`moonlight.bin` upstream — so removing the wrapper restores the original
single-file layout.)

## Things that look like fixes but are NOT

- `SDL_VIDEODRIVER=fbcon`, `SDL_FBDEV=/dev/fb0`: cargo-culted from older
  guides; fbcon doesn't exist in muOS's SDL2.
- `SDL_VIDEODRIVER=kmsdrm`: `/dev/dri` doesn't exist on this kernel.
- `LD_LIBRARY_PATH=/mnt/mmc/MUOS/application/moonlight_libs`: that path
  doesn't exist either, so it's a silent no-op.
- Replacing `/usr/lib/libmoonlight-common.so.4`: works but breaks the
  upstream love-based GUI which links against the same lib.  Keep the
  wrapper, leave `/usr/lib` alone.
