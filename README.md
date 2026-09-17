<img width="200" height="168" alt="Sony-PlayStation-3-Eye (2)" src="https://github.com/user-attachments/assets/cdd1fcbe-1eac-4c86-b982-e7df747f6483" />


# PS3Eye-VirtualCam (Intel)

An Intel/x86_64 build of [BH2VOQ/PS3-Camera-macOS-Driver](https://github.com/BH2VOQ/PS3-Camera-macOS-Driver), which turns a PlayStation 3 Eye camera into a system-wide macOS virtual camera. The upstream project only ships an Apple Silicon (arm64) build; this fork replaces the arm64-only static `libusb` with a Homebrew-linked build so it compiles and runs on Intel Macs and Intel-based Hackintosh systems.

![Platform](https://img.shields.io/badge/platform-macOS%20Intel%20%2F%20Hackintosh-lightgrey?style=flat-square)
![License](https://img.shields.io/badge/license-GPLv2-blue?style=flat-square)

## What it does

Exposes the PS3 Eye as a standard system camera — usable in Zoom, Discord, Teams, browsers, QuickTime, and anything else that lists cameras — with no kernel extension. Everything runs in userspace via `libusb`, feeding frames into the OBS Virtual Camera's CoreMediaIO extension.

## Why a fork was needed

Upstream ships a static `libusb-1.0.a` built only for arm64 and hard-codes `-arch arm64` in `build.sh`. None of the actual source (`ps3eye-feed.mm`, `ps3eye.cpp`, the menu bar app) contains any architecture-specific code — it's plain C++/Objective-C. The only change required was to `build.sh`:

- Removed the `-arch arm64` flag.
- Replaced the vendored static `libusb-1.0.a` with `pkg-config --cflags/--libs libusb-1.0` against a Homebrew-installed `libusb`.

Everything else (`build-app.sh`, `install-agent.sh`, the menu app, the feeder) is unchanged from upstream.

## How it works

1. `ps3eye-feed` (a small background process, installed as a LaunchAgent) captures frames from the camera via `libusb` and writes them directly into the system's CoreMediaIO camera extension — the one OBS Studio installs the first time it's launched.
2. The menu bar app (`PS3-Camera-macOS-Driver.app`) toggles the physical camera on/off and self-installs on first launch (copies the feeder to `~/Library/Application Support` and registers the LaunchAgent) — no need to manually run `install-agent.sh` if you use the app.
3. OBS Studio does **not** need to stay open. It's only required once, to register the "OBS Virtual Camera" device with the system.

## Requirements

- Intel (x86_64) Mac, or an x86_64 Hackintosh
- macOS 12.3 or later (minimum for the Camera Extension API)
- Xcode Command Line Tools (`xcode-select --install`)
- Homebrew, with `brew install libusb pkg-config`
- OBS Studio, installed and launched at least once, with "OBS Virtual Camera" approved by the system

## Build

> **Note:** you can skip this whole section by downloading the pre-built app from the [latest release](../../releases/latest) instead.

```bash
git clone https://github.com/rbx-br/PS3-Camera-macOS-Driver-Intel.git
cd PS3-Camera-macOS-Driver-Intel
./build.sh
./scripts/build-app.sh
```

The finished app is at `dist/PS3-Camera-macOS-Driver.app`. Copy it to `/Applications`, open it (right-click → Open if Gatekeeper blocks it, since the build is ad-hoc signed, not notarized), then click **Enable Camera** in the menu bar.

## Troubleshooting

- Live log: `tail -f "$HOME/Library/Logs/PS3Eye-VirtualCam/feed.log"`
- Reinstall the LaunchAgent: `./scripts/install-agent.sh`
- Restart the feeder: `launchctl kickstart -k "gui/$(id -u)/com.bh2voq.ps3eye-vcam"`
- If the camera isn't detected on a Hackintosh, try a different physical USB port before suspecting the code — `libusb` can be flaky on ports mapped through custom SSDT/kext USB injection.

## Credits

- [inspirit/PS3EYEDriver](https://github.com/inspirit/PS3EYEDriver) — original userspace libusb driver
- [obs-mac-virtualcam](https://github.com/johnboiles/obs-mac-virtualcam) — OBS virtual camera groundwork
- [BH2VOQ/PS3-Camera-macOS-Driver](https://github.com/BH2VOQ/PS3-Camera-macOS-Driver) — combined the above with a CoreMediaIO feeder and menu bar app (Apple Silicon build)

## License

GPLv2, inherited from upstream.
