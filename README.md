# CODM Downscaling Beta

Developed by **zynn**

A CODM-only WebUI root module for applying downscaling and FPS-related game settings from a simple interface. This project is packaged for rooted Android devices using a root manager with WebUI support.

## Features
- CODM-only targeting
- WebUI control panel
- Resolution downscaling presets
- FPS target selection
- Refresh-rate lock option
- Auto-reapply when CODM launches
- Live log/output panel
- Custom banner and branded UI

## Supported packages
- `com.activision.callofduty.shooter`
- `com.garena.game.codm`
- `com.tencent.tmgp.kr.codm`

## Requirements
- Root access
- KernelSU or another supported root manager with WebUI support
- Device and ROM support for Android game downscale commands may vary

## Installation
1. Download the latest zip from the `release/` folder or from GitHub Releases.
2. Open your root manager.
3. Flash the zip.
4. Reboot if your setup requires it.
5. Open the module WebUI and choose your CODM package and settings.

## Project structure
```text
CODM-Downscaling-Zynn/
├── README.md
├── RELEASE_NOTES.md
├── .gitignore
├── screenshots/
│   └── banner-preview.png
├── release/
│   └── codm_downscaling_zynn_branding.zip
└── module_source/
    ├── module.prop
    ├── customize.sh
    ├── common.sh
    ├── apply.sh
    ├── reset.sh
    ├── service.sh
    ├── banner.png
    └── webroot/
```

## Notes
- This is a beta release.
- Actual downscaling behavior depends on Android version, ROM, kernel, and vendor implementation.
- Some devices may ignore parts of the game overlay or downscale commands.

## Credits
- Developed by **zynn**
