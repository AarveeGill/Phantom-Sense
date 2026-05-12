# Changelog

All notable changes to PhantomSense will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.2.0] - 2026-05-12

### Steam Deck

**Added — `install-phantomsense-deck.sh` v1.2.0** (complete rewrite)

- Runs VirtualHere as a system service with root access.
- Auto-starts at boot in Desktop Mode and Game Mode.
- Creates a desktop shortcut (shows service status, IP address, quick commands).
- Generates `restore-service.sh` in `/home/deck/phantomsense/` for one-command recovery after SteamOS updates.
- Detects and cleans up the old v1.1.0 user service automatically.
- Flags: `--status`, `--uninstall`, `--force`, `--help`.

**Fixed**

- Permission denied (exit code 2) — VirtualHere needs root to access USB devices. Moved from user service to system service with `User=root`.
- No auto-start in Game Mode — user services with linger only start after login. System services start at boot regardless of mode.

**Removed**

- Linger-based user service approach from v1.1.0.

### Windows PC

**Added — `install-phantomsense-pc.bat`** (new file)

- Double-click launcher. No PowerShell commands needed.
- Auto-elevates to Administrator (single UAC prompt).
- Bypasses execution policy automatically.
- Downloads `install-phantomsense-pc.ps1` from GitHub to a temp directory and runs it.

**Added — `install-phantomsense-pc.ps1` v1.1.0** (new file)

- Downloads and installs VirtualHere Client with a desktop shortcut.
- Installs ViGEmBus driver (silent).
- Installs HidHide driver (optional, skippable with `-SkipHidHide`).
- Configures Sunshine (`controller = disabled`) with automatic backup of the original config file.
- DSX installation — interactive choice between free v1.4.9 from GitHub and paid v3.x from Steam.
- Prompts for Steam Deck IP address for VirtualHere hub configuration.
- Flags: `-Status`, `-Uninstall`, `-Force`, `-SkipHidHide`, `-Help`.

### Documentation

**Changed — `README.md`**

- Full redesign. Clean markdown, natural prose, minimal HTML.
- Added "Who is this for?" section explaining the PC + Moonlight + Steam Deck ecosystem and three usage modes (handheld, docked, bridge).
- Added Quick Install section (curl one-liner for Deck, double-click .bat for PC).
- Manual setup phases retained and cleaned up.
- Research comparison table, troubleshooting, and FAQ carried over from v1.0.0.

**Added — `CHANGELOG.md`**

- This file.

---

## [1.1.0] - 2026-05-11

### Steam Deck

**Added — `install-phantomsense-deck.sh` v1.1.0** (first installer)

- Downloads VirtualHere USB Server binary.
- Creates a systemd user service with linger for auto-start.
- Displays Steam Deck IP address after installation.

**Known Issues**

- VirtualHere exits with code 2 (permission denied). The user service runs without root, but VirtualHere requires root to access USB devices.
- No desktop shortcut.
- No recovery mechanism for SteamOS updates wiping the service file.

---

## [1.0.0] - 2026-05-11

### Documentation

**Added — `README.md`**

- Complete manual setup guide for DualSense USB forwarding via VirtualHere (six phases).
- Sunshine/Moonlight configuration for video-only streaming.
- DSX integration for Adaptive Triggers, HD Haptics, Gyro, and Touchpad.
- systemd auto-start service configuration for Steam Deck.
- Backup script for SteamOS update recovery.
- Full research and comparison of all investigated approaches.
- Troubleshooting guide and FAQ.
- Open-source USB/IP fallback guide.
- Network topology documentation.
- Performance and latency analysis.

**Added — `LICENSE`**

- MIT License.
