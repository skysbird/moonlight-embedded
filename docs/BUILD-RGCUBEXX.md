# Build manual — Moonlight Embedded for RG Cube XX (muOS)

This is the canonical build path for the muOS / RK3566 target.  Everything
described here produces a binary that drops into the wrapper-based deploy
documented in [DEPLOY-RGCUBEXX.md](DEPLOY-RGCUBEXX.md).

## Targets

| | |
|---|---|
| Device  | Anbernic RG Cube XX (also tested on TrimUI Smart Pro layout) |
| SoC     | Rockchip RK3566 (4× Cortex-A55) |
| GPU     | Mali-G52 |
| Arch    | aarch64 / ARMv8.2-A |
| OS      | muOS 2601.0 (JACARANDA) and compatible |

## TL;DR — Docker build

```
# Linux / macOS / WSL
docker build -t moonlight-rgcubexx -f Dockerfile.rgcubexx .
docker run --rm -v "$PWD:/workspace/moonlight-embedded" moonlight-rgcubexx
# -> build-rgcubexx/moonlight-rgcubexx (stripped binary)
```

```
:: Windows (PowerShell or cmd)
docker-build.bat
```

The Dockerfile builds the cross toolchain plus all required deps as
**static** libs into `/opt/rgcubexx`:

  util-linux (libuuid) · libevdev · eudev (libudev) · Opus · ALSA-lib ·
  SDL2 (alsa+evdev only, no x11/wayland/opengl-desktop)

`build-minimal.sh` then runs cmake against that prefix and produces the
moonlight binary.

## Build options that actually matter

`build-minimal.sh` already picks them, but if you customise:

| Flag | Setting | Why |
|---|---|---|
| `-DENABLE_X11=OFF` | off | no X server on muOS |
| `-DENABLE_PULSEAUDIO=OFF` | off | muOS uses ALSA |
| `-DENABLE_OPENGL=OFF` | off | desktop GL not present |
| `-DENABLE_OPENGLES=OFF` | off | RKMPP / SDL handle output |
| `-DENABLE_RK=ON` | on | use Rockchip platform decoder if available |
| `-DENABLE_SDL=ON` | on | SDL fallback path (the one the user sees) |
| `-DENABLE_FFMPEG=ON` | on (preferred) | required for the working static build, see note |
| `-march=armv8.2-a -mtune=cortex-a55 -O3` | yes | RK3566 ISA hints |

> **FFmpeg note.** muOS only ships `libavcodec.so.58` / `libavutil.so.56`
> (FFmpeg 4.4.x).  A binary built against a newer ffmpeg (LIBAVCODEC_59 /
> LIBAVUTIL_57 symbols) will refuse to load on the device.  Either build
> against ffmpeg 4 dynamically, **or** statically link ffmpeg 4 into the
> moonlight binary itself.  The shipped release uses the latter — the
> 9.6 MB binary contains its own `ffmpeg 4.4.2`.

## Native cross-build (no Docker)

```
sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu cmake
./build-rgcubexx.sh        # produces build-rgcubexx/moonlight-rgcubexx
```

This pulls deps from `/opt/rgcubexx` if it exists (created by the
Dockerfile at the same path), otherwise from the host.

## Producing a release package

After a successful build, package the binary plus the matching
`.so.4` libs into a deployable zip.  The wrapper/launch/install scripts
live under `packaging/` and are bundled automatically:

```
scripts/package-rgcubexx.sh \
  --binary     <path>/moonlight \
  --common     <path>/libmoonlight-common.so.4 \
  --gamestream <path>/libgamestream.so.4 \
  --version    2.7.1-muos.1
# -> release/moonlight-rgcubexx-2.7.1-muos.1.zip
```

The `.so.4` files MUST come from the same source tree as the binary —
shipping a moonlight built against a different libmoonlight-common ABI
is exactly the failure mode that motivates the wrapper.  See
[DEPLOY-RGCUBEXX.md](DEPLOY-RGCUBEXX.md) for the full root-cause writeup.
