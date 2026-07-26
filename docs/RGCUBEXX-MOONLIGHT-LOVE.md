# RG Cube XX Moonlight Love Notes

This repo does not currently own the upstream Love frontend as tracked source.
The `device-main.lua` and `device-mux_launch.sh` files are patched copies pulled
from a muOS Moonlight installation for deployment/debugging.

## Device-Side Fixes

- `device-main.lua`
  - Adds the controller mapping argument:
    `-mapping /usr/lib/gamecontrollerdb.txt`
  - Keeps `720x720` launches at `60fps`.
  - Writes Moonlight commands with host last and `-port` before the host.

- `device-mux_launch.sh`
  - Logs each launch to `/tmp/moonlight-last.log`.
  - Runs the packaged `moonlight` wrapper so bundled libraries are loaded before
    stale muOS system libraries.

The normal Moonlight exit combo on the handheld is:

```text
Select + Start + L1 + R1
```

## Sunshine / MTT VDD 720x720

For RG Cube XX's square panel, Sunshine should be allowed to switch the MTT
Virtual Display Driver to `720x720@60`.

Sunshine config needs display-device auto switching enabled, for example:

```text
dd_config_revert_on_disconnect = enabled
dd_configuration_option = ensure_only_display
dd_resolution_option = auto
dd_refresh_rate_option = auto
output_name = {MTT_DEVICE_ID_FROM_SUNSHINE}
```

MTT VDD also needs `720x720` in:

```text
C:\VirtualDisplayDriver\vdd_settings.xml
```

Add this under `<resolutions>` if it is missing:

```xml
<resolution>
  <width>720</width>
  <height>720</height>
  <refresh_rate>30</refresh_rate>
</resolution>
```

The global refresh-rate list should include `60`:

```xml
<g_refresh_rate>60</g_refresh_rate>
```

After editing the XML, restart the `ROOT\DISPLAY\0000` MTT VDD device and then
restart Sunshine. A successful stream shows these Sunshine log lines:

```text
Capture size       : 720x720
Desktop resolution [720x720]
Display refresh rate [60Hz]
```

## Host Rescue Hotkey

`tools/moonlight-display-rescue.ps1` is a host-side rescue action. It stops
Sunshine, switches Windows back to the internal/local display, then starts
Sunshine again. It can be wired to a Windows shortcut or scheduled task hotkey
such as `Ctrl + Alt + M`.
