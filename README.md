<div align="center">

# PhantomSense

**Forward a DualSense from your Steam Deck to your PC over the network.**  
Adaptive triggers, HD haptics, gyro, and touchpad — all working natively over Moonlight.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20SteamOS-lightgrey?style=for-the-badge&logo=steam)](https://store.steampowered.com/steamdeck)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-green?style=for-the-badge)](https://github.com/AarveeGill/Phantom-Sense/commits/main)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge)](https://github.com/AarveeGill/Phantom-Sense/pulls)
[![Stars](https://img.shields.io/github/stars/AarveeGill/Phantom-Sense?style=for-the-badge)](https://github.com/AarveeGill/Phantom-Sense/stargazers)

</div>

---

PhantomSense is a turnkey setup pipeline that forwards a DualSense controller from a Steam Deck to a Windows PC using USB/IP. Your PC sees a real, wired DualSense — not a virtual Xbox pad — so every advanced feature works natively. Moonlight carries the video. VirtualHere carries the controller. Total cost is zero.

> Demo video coming soon — see [Roadmap](#roadmap).

---

## Why this exists

Moonlight translates every controller into a virtual Xbox 360 gamepad before it reaches the PC. Adaptive triggers, HD haptics, gyro, and touchpad are stripped in that translation. Sunshine on Windows only supports Xbox 360 and DualShock 4 emulation. Native DualSense emulation exists only on Linux, and even there, adaptive triggers are blocked by SDL limitations.

```
DualSense --> Steam Deck --> Moonlight --> [XInput Translation] --> Virtual Xbox Pad
                                                  ^
                                          Features lost here.
```

PhantomSense bypasses this entirely. It forwards the DualSense as a raw USB device over the network, so Windows believes the controller is physically plugged in. DSX picks it up. Everything works.

```
DualSense --> Steam Deck --> VirtualHere USB/IP --> Network --> PC sees native DualSense
              Steam Deck --> Moonlight --------------------------> Sunshine (video + audio only)
                                                                         |
                                                                     DSX on PC
                                                                 Adaptive Triggers  [works]
                                                                 HD Haptics         [works]
                                                                 Gyro               [works]
                                                                 Touchpad           [works]
```

Two parallel data paths. They never interfere.

---

## Who is this for
<br>

<div align="center">
<table>
<tr>
<td align="center" width="33%">

**Your Gaming PC**

The powerhouse. Sits in your main room or office. Runs every AAA title at max settings. It's always on, always ready.

</td>
<td align="center" width="33%">

**TVs Around The House**

Living room. Bedroom. Basement. You've set up **Moonlight + Sunshine** to stream PC games to every screen in the house.

</td>
<td align="center" width="33%">

**Your Steam Deck**

Your portable companion. Play on the couch, on a TV via HDMI, or in bed. It can also run games natively — but it really shines as a **streaming powerhouse**.

</td>
</tr>
</table>
</div>

<br>

**If this sounds like your setup, keep reading.** You have a powerful PC that does the heavy lifting, and **Moonlight/Sunshine** beaming those games to every room. Maybe you game on the living room TV with a Steam Deck docked via HDMI. Maybe you play handheld on the couch. Maybe both, depending on the day.

Now add a **DualSense** to the mix — Sony's flagship controller with adaptive triggers, HD haptics, gyroscope, and touchpad. You paid a premium for those features. You expect them to work.

**They don't.** When Moonlight streams your game, it converts the DualSense into a generic Xbox 360 gamepad. Every premium feature is silently killed. Your $200 controller feels like a $20 one.

<br>

<div align="center">
<table>
<tr>
<td>Adaptive Triggers — <strong>Lost</strong></td>
<td>HD Haptics — <strong>Lost</strong></td>
<td>Gyroscope — <strong>Lost</strong></td>
<td>Touchpad — <strong>Lost</strong></td>
</tr>
</table>
</div>

<br>

### PhantomSense Fixes This

Plug your DualSense into the Steam Deck via USB-C. PhantomSense forwards that controller as a **raw USB device** directly to your PC over the network — bypassing Moonlight entirely. Your PC sees a real, wired DualSense. Every feature works.

<br>

<div align="center">
<table>
<tr>
<td align="center" width="33%">

**Handheld Mode**

Stream from PC to Deck. DualSense plugged into Deck. Play on the Deck's screen with full trigger and haptic feedback.

</td>
<td align="center" width="33%">

**Docked Mode**

Deck connected to a TV via HDMI. DualSense plugged into Deck. Big screen gaming with every DualSense feature alive.

</td>
<td align="center" width="33%">

**Bridge Mode**

Gaming on any TV in the house. Deck sits nearby as a **USB bridge** — its only job is forwarding the DualSense to your PC.

</td>
</tr>
</table>
</div>


---

## Quick install

**Steam Deck** — open Konsole in Desktop Mode:

```bash
curl -sL https://raw.githubusercontent.com/AarveeGill/Phantom-Sense/main/install-phantomsense-deck.sh | bash
```

**Windows PC** — download [`install-phantomsense-pc.bat`](install-phantomsense-pc.bat) and double-click it. Handles admin elevation, downloads, and full setup. No terminal needed.

After both scripts finish: plug the DualSense into the Deck, open VirtualHere Client on the PC, attach the controller, launch DSX. Done.

> [!TIP]
> The Deck installer creates a systemd service (auto-starts at boot in Desktop and Game Mode), a desktop shortcut, and a restore script for SteamOS updates. The PC installer handles VirtualHere Client, ViGEmBus, HidHide, Sunshine config, and DSX.

---

## What this enables

PhantomSense is the pipeline. These are the capabilities it unlocks:

| Capability | How |
|:-----------|:----|
| Adaptive triggers | Per-game resistance profiles through DSX |
| HD haptics | Precision feedback via DualSense audio channels |
| Gyroscope | Full 6-axis motion passthrough |
| Touchpad | Native multi-touch input |
| Zero cost | VirtualHere free tier covers exactly one USB device |
| Low latency | USB/IP over LAN adds ~1–3 ms |
| Auto-start on boot | Systemd service runs in Desktop and Game Mode |
| Survives SteamOS updates | Binary persists in /home/deck/; restore script rebuilds the service |
| Tailscale-ready | Works over encrypted mesh VPN |
| Standard DualSense support | Not just the Edge — both models work identically |

---

## Requirements

### Hardware

| Device | Notes |
|:-------|:------|
| Gaming PC | Windows 10 or 11 |
| Steam Deck | SteamOS — handheld, docked, or bridge mode |
| DualSense | Edge or standard |
| USB-C cable | Connects DualSense to Steam Deck |
| Local network | Same LAN, or Tailscale |

### Software

| Software | Role | Where | Link |
|:---------|:-----|:------|:-----|
| Sunshine | Stream host | PC | [LizardByte/Sunshine](https://github.com/LizardByte/Sunshine) |
| Moonlight | Stream client | Deck | [moonlight-stream.org](https://moonlight-stream.org/) |
| VirtualHere Server | USB/IP server | Deck | [virtualhere.com](https://www.virtualhere.com/usb_server_software) |
| VirtualHere Client | USB/IP client | PC | [virtualhere.com](https://www.virtualhere.com/usb_client_software) |
| DSX (DualSenseX) | Triggers + haptics engine | PC | [Steam](https://store.steampowered.com/app/1812620/DSX/) / [GitHub](https://github.com/Paliverse/DualSenseX) |
| Tailscale *(optional)* | Mesh VPN | Both | [tailscale.com](https://tailscale.com/) |

---

## How it works

```
+------------------------------------------------------------------+
|                    STEAM DECK (Room B)                            |
|                                                                   |
|  +-----------+  USB-C  +--------------------+                     |
|  | DualSense |-------->| VirtualHere Server |                     |
|  +-----------+         +--------+-----------+                     |
|                                 | TCP :7575                       |
|  +-------------------+          |                                 |
|  |    Moonlight      |          |                                 |
|  | (video/audio only)|<---+     |                                 |
|  +-------------------+    |     |                                 |
+---------------------------+-----+---------------------------------+
                            |     |
                     +------+-----+------+
                     |   Network (LAN)   |
                     +------+-----+------+
                            |     |
+---------------------------+-----+---------------------------------+
|                    GAMING PC (Room A)                             |
|                           |     |                                 |
|  +-------------------+    |     |                                 |
|  |    Sunshine       |----+     |                                 |
|  | controller = off  |          |                                 |
|  +-------------------+          |                                 |
|                                 |                                 |
|  +--------------------+ USB/IP  |                                 |
|  | VirtualHere Client |<--------+                                 |
|  +--------+-----------+                                           |
|           | appears as local USB                                  |
|  +--------v-----------+                                           |
|  |       DSX          |                                           |
|  | Adaptive Triggers  |                                           |
|  | HD Haptics         |                                           |
|  | Gyro + Touchpad    |                                           |
|  +--------+-----------+                                           |
|           |                                                       |
|  +--------v-----------+                                           |
|  |       Game         |                                           |
|  +--------------------+                                           |
+------------------------------------------------------------------+
```

---

## Alternatives considered

| Approach | Latency | Cost | Complexity | Full DS features | SteamOS compatible |
|:---------|:-------:|:----:|:----------:|:----------------:|:------------------:|
| **PhantomSense (VirtualHere)** | ~2–4 ms | Free | Medium | Yes | Yes |
| USB/IP open-source | ~1–3 ms | Free | High | Yes | Yes |
| Sunshine DS4 emulation | <1 ms | Free | Low | No | Yes |
| Sunshine DS5 (Linux only) | <1 ms | Free | Medium | No | N/A |
| DS5Dongle (RPi Pico 2W) | ~1 ms | $7–16 | Low | Yes | No |

VirtualHere won because the free tier supports exactly one USB device — which is exactly what this needs. Signed Windows drivers, auto-discovery, a single static binary on SteamOS, and years of production use. The $49 license is only for forwarding multiple devices.

---

## Performance

| Component | Added latency | Notes |
|:----------|:------------:|:------|
| VirtualHere USB/IP (LAN) | ~1–3 ms | TCP encapsulation, negligible |
| Moonlight / Sunshine video | ~5–15 ms | Encoder and network dependent |
| DSX processing | <1 ms | Local |
| **Total controller overhead** | **~1–3 ms** | Imperceptible vs. direct USB |

The dominant latency is always the video stream, never the controller.

---

## Cost

| Item | Cost |
|:-----|-----:|
| VirtualHere Server (free tier, 1 device) | $0 |
| VirtualHere Client | $0 |
| DSX (free version) | $0 |
| Moonlight | $0 |
| Sunshine | $0 |
| Tailscale (personal) | $0 |
| **Total** | **$0** |

VirtualHere's free tier has no time limit. The $49 license is only for multiple devices. DSX's paid DLC (~$4.99) adds extra haptic modes; the free version covers the essentials.

---

## Your gaming session

Once set up, each session is:

1. Power on the Steam Deck. VirtualHere starts automatically.
2. Plug in the DualSense. VirtualHere Client on the PC auto-attaches it.
3. DSX detects the controller. Triggers and haptics activate.
4. Open Moonlight on the Deck, connect to Sunshine, pick a game.
5. Play. Full DualSense, from the other room.

The DualSense is forwarded to the PC, so it won't control the Deck locally. Use the Deck's touchscreen or built-in controls to navigate Moonlight.

---

## Manual setup

> [!TIP]
> If you used [Quick install](#quick-install), skip this entirely.

<details>
<summary><strong>Phase 1 — VirtualHere Server on Steam Deck</strong></summary>

Switch to Desktop Mode. Open Konsole.

```bash
passwd                          # set a password if you haven't
mkdir -p ~/Documents/virtualhere
cd ~/Documents/virtualhere
wget https://www.virtualhere.com/sites/default/files/usbserver/vhusbdx86_64
chmod +x vhusbdx86_64
sudo ./vhusbdx86_64             # plug DualSense in first
```

You should see `VirtualHere USB Server x86_64 running...`

> [!WARNING]
> Closing the terminal kills the server. See Phase 6 for auto-start.

</details>

<details>
<summary><strong>Phase 2 — VirtualHere Client on Windows</strong></summary>

Download the [VirtualHere Windows Client](https://www.virtualhere.com/usb_client_software) and run it. The Deck should appear within ~15 seconds.

If it doesn't (common with multi-router setups): right-click the top node > Specify Hubs > Add > enter `<Steam_Deck_IP>:7575`.

</details>

<details>
<summary><strong>Phase 3 — Forward the DualSense</strong></summary>

Expand the Steam Deck node. Right-click the DualSense > Use this device. Windows installs HID drivers automatically. Status should read "In use by you".

Verify in Device Manager: Sony HID entry under Human Interface Devices, and a new audio device under Sound (haptics use audio channels).

</details>

<details>
<summary><strong>Phase 4 — DSX setup</strong></summary>

Install [DSX](https://store.steampowered.com/app/1812620/DSX/) from Steam. Install [ViGEmBus](https://github.com/nefarius/ViGEmBus/releases) (required) and [HidHide](https://github.com/nefarius/HidHide/releases) (optional, prevents double-input).

Launch DSX. It should detect the DualSense as a wired USB controller. Open the trigger test panel, apply a preset like Rigid or Pulse. If the triggers push back, PhantomSense is working.

</details>

<details>
<summary><strong>Phase 5 — Sunshine / Moonlight config</strong></summary>

Disable controller passthrough to prevent double input.

In Sunshine (`https://localhost:47990`) > Configuration > Input > set Controller to `disabled`. Or add to `sunshine.conf`:

```ini
controller = disabled
```

Moonlight now carries video and audio only.

</details>

<details>
<summary><strong>Phase 6 — Auto-start on boot</strong></summary>

> [!TIP]
> The Quick Install script handles this automatically, including the restore script.

```bash
sudo nano /etc/systemd/system/virtualhere.service
```

```ini
[Unit]
Description=VirtualHere USB Server
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/home/deck/Documents/virtualhere/vhusbdx86_64
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable virtualhere.service
sudo systemctl start virtualhere.service
```

SteamOS updates can wipe `/etc/systemd/system/`. The binary in `/home/deck/` survives. Keep a restore script to recreate the service, or use Quick Install, which saves one at `~/phantomsense/restore-service.sh`.

</details>

---

## Troubleshooting

<details>
<summary>VirtualHere Client shows nothing</summary>

- Server not running: `sudo systemctl status phantomsense`
- Different subnets: manually add the hub at `<Deck_IP>:7575`
- Firewall: `sudo iptables -A INPUT -p tcp --dport 7575 -j ACCEPT`

</details>

<details>
<summary>DSX does not detect the DualSense</summary>

- VirtualHere must show "In use by you"
- Check Device Manager for a Sony HID entry
- Unplug and re-plug USB-C, re-attach in VirtualHere
- Restart DSX

</details>

<details>
<summary>Double input or ghost controller</summary>

- Set `controller = disabled` in Sunshine config
- Whitelist only DSX in HidHide
- Confirm Moonlight isn't forwarding a virtual pad

</details>

<details>
<summary>HD haptics not working</summary>

- Haptics use audio channels (4-channel device: 2 headphone, 2 haptic)
- Check Windows Sound Settings for a DualSense audio device
- Confirm the haptic channels aren't muted

</details>

<details>
<summary>Service wiped after SteamOS update</summary>

- Binary survives in `/home/deck/` — only the systemd unit is wiped
- Quick Install users: `sudo ~/phantomsense/restore-service.sh`
- Manual users: recreate from Phase 6

</details>

<details>
<summary>Noticeable input latency</summary>

- Use wired Ethernet instead of Wi-Fi
- In VirtualHere Client: right-click hub > Optimize for Interactive (Low Latency)
- Try Tailscale for a more direct route through double-NAT

</details>

---

## FAQ

<details>
<summary>Does it work with the standard DualSense (non-Edge)?</summary>

Yes. Both models use the same HID protocol.

</details>

<details>
<summary>Can I use the DualSense on the Deck and PC at the same time?</summary>

No. USB/IP detaches it from the Deck. Use the Deck's own controls for Moonlight navigation.

</details>

<details>
<summary>Does this work over the internet?</summary>

Yes, with a VPN like Tailscale. LAN is recommended for gaming latency.

</details>

<details>
<summary>What about anti-cheat?</summary>

Some engines may flag VirtualHere's virtual USB hub driver. Best suited for single-player and co-op titles.

</details>

<details>
<summary>Do DSX game-specific profiles work?</summary>

Yes. DSX sees a normal wired USB DualSense. Every profile and trigger configuration works.

</details>

---

## Fallback — open-source USB/IP

<details>
<summary>Fully open-source setup without VirtualHere</summary>

### Steam Deck

```bash
sudo steamos-devmode enable
sudo pacman -S usbip
sudo modprobe usbip-core usbip-host
sudo usbipd -D
usbip list -l
sudo usbip bind -b X-Y   # replace with actual bus ID
```

### Windows

Use [usbip-win2](https://github.com/vadimgrn/usbip-win2) — actively maintained with WHLK-certified drivers.

### Trade-offs

| | USB/IP (open source) | VirtualHere |
|:--|:--:|:--:|
| Cost | Free | Free (1 device) |
| Stability | Occasional BSOD risk | Very stable |
| SteamOS persistence | Wiped on updates | Survives |
| Complexity | High | Medium |
| Auto-discovery | Manual | Automatic |

</details>

---

## Network topology

<details>
<summary>Reference diagram</summary>

```
         +------------------+
         |    Gaming PC     |
         |  Sunshine        |
         |  VH Client       |
         |  DSX             |
         +--------+---------+
                  |  Ethernet
         +--------+---------+
         |    Router 1      |
         +--------+---------+
                  |  Ethernet
         +--------+---------+
         |    Router 2      |
         +--------+---------+
                  |  Wi-Fi
         +--------+---------+
         |    Steam Deck    |
         |  VH Server       |
         |  Moonlight       |
         |  DualSense <-- USB-C
         +------------------+
```

If auto-discovery fails, the two routers likely put devices on different subnets. Add the hub manually or use Tailscale.

</details>

---

## Security

PhantomSense install scripts run with elevated privileges (`sudo` on Linux, Administrator on Windows). They download binaries from official sources (VirtualHere, GitHub releases for ViGEmBus and HidHide). Review the scripts before running them. All source URLs point to the original vendor distribution pages.

If you find a security issue, open a [GitHub issue](https://github.com/AarveeGill/Phantom-Sense/issues) with the `security` label.

---

## Roadmap

- [x] One-click setup script for Steam Deck
- [x] One-click setup script for Windows PC
- [x] Double-click .bat launcher for Windows
- [ ] `phantomsense --status` diagnostic check
- [ ] Decky Loader plugin for Game Mode integration
- [ ] Video walkthrough and demo
- [ ] Wired vs. Wi-Fi latency benchmarks
- [ ] Tailscale WAN configuration guide
- [ ] Game compatibility matrix
- [ ] Track Sunshine DS5 emulation — [LizardByte #652](https://github.com/orgs/LizardByte/discussions/652)

---

## Contributing

Bug reports, documentation improvements, script enhancements, game compatibility reports, and alternative network configurations are all welcome. Open an [issue](https://github.com/AarveeGill/Phantom-Sense/issues) or submit a [pull request](https://github.com/AarveeGill/Phantom-Sense/pulls).

---

## Credits

| Project | Author | Role in PhantomSense |
|:--------|:-------|:---------------------|
| [VirtualHere](https://www.virtualhere.com/) | VirtualHere Pty. Ltd. | USB/IP transport layer |
| [DSX / DualSenseX](https://github.com/Paliverse/DualSenseX) | Paliverse | Adaptive triggers and haptics engine |
| [Sunshine](https://github.com/LizardByte/Sunshine) | LizardByte | Open-source stream host |
| [Moonlight](https://github.com/moonlight-stream) | moonlight-stream | Stream client |
| [DS5Dongle](https://github.com/awalol/DS5Dongle) | awalol | Validated wired DualSense = full features |
| [usbip-win2](https://github.com/vadimgrn/usbip-win2) | vadimgrn | Open-source USB/IP client |
| [Steam Deck USB/IP](https://github.com/kalvinarts/steam-deck-usbip) | kalvinarts | Pioneered USB/IP on SteamOS |

And every forum poster, Reddit commenter, and GitHub contributor whose scattered fragments helped piece this together.

---

## License

[MIT License](LICENSE) — Copyright (c) 2026 Rajvinder Singh

---

<div align="center">

**Your PC sees a DualSense that isn't there. That's PhantomSense.**

If this helped, a star helps others find it.

</div>
