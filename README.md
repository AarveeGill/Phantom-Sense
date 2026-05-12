<!-- ═══════════════════════════════════════════════════════════════════════
     PhantomSense — Your PC sees a DualSense that isn't there.
     https://github.com/AarveeGill/Phantom-Sense
     ═══════════════════════════════════════════════════════════════════════ -->

<div align="center">

<br>

<img src="https://img.shields.io/badge/-%F0%9F%8E%AE%20PhantomSense-000000?style=for-the-badge&labelColor=000000" alt="PhantomSense" width="280">

<br>

### Your PC sees a DualSense that isn't there.

<br>

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="MIT License"></a>
  <a href="https://store.steampowered.com/steamdeck"><img src="https://img.shields.io/badge/Platform-Windows%20%7C%20SteamOS-lightgrey?style=for-the-badge&logo=steam" alt="Platform"></a>
  <a href="https://github.com/AarveeGill/Phantom-Sense/commits/main"><img src="https://img.shields.io/badge/Maintained-Yes-green?style=for-the-badge" alt="Maintained"></a>
  <a href="https://github.com/AarveeGill/Phantom-Sense/pulls"><img src="https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge" alt="PRs Welcome"></a>
  <a href="https://github.com/AarveeGill/Phantom-Sense/stargazers"><img src="https://img.shields.io/github/stars/AarveeGill/Phantom-Sense?style=for-the-badge" alt="Stars"></a>
  <a href="https://github.com/AarveeGill/Phantom-Sense/issues"><img src="https://img.shields.io/github/issues/AarveeGill/Phantom-Sense?style=for-the-badge" alt="Issues"></a>
</p>

</div>

<!-- ═══════════════════════════════════════════════════════════════════════
     WHO IS THIS FOR?
     ═══════════════════════════════════════════════════════════════════════ -->

## Who Is This For?

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

<br>

> [!NOTE]
> **The Steam Deck is the key.** Whether you're playing on its screen, on a TV, or just using it as a bridge — the Deck is what connects your DualSense to the PC over the network. PhantomSense makes the connection invisible. Your PC thinks the controller is plugged directly in.

<br>

<div align="center">

**The total cost is zero dollars.**

> *"Built this because I refused to accept that a pro controller*
> *should feel like a $20 gamepad just because it's in another room."*

<br>

<!-- DEMO — replace with your own GIF or video link
![PhantomSense Demo](assets/demo.gif)
-->

**If PhantomSense helped you, a star helps others find it.**

</div>

<br>

## Quick Install

**Steam Deck** — open Konsole in Desktop Mode:

```bash
curl -sL https://raw.githubusercontent.com/AarveeGill/Phantom-Sense/main/install-phantomsense-deck.sh | bash
```

**Windows PC** — download [`install-phantomsense-pc.bat`](install-phantomsense-pc.bat) from this repo and double-click it. It handles admin elevation, execution policy, downloading the installer, and running the full setup. No terminal needed.

After both scripts finish, plug the DualSense into the Deck, open VirtualHere Client on the PC, attach the controller, and launch DSX. You're done.

> [!TIP]
> The Deck installer creates a system service that auto-starts at boot (Desktop Mode and Game Mode), a desktop shortcut, and a restore script for SteamOS updates. The PC installer handles VirtualHere Client, ViGEmBus, HidHide, Sunshine config, and DSX.

---

## The Problem

When Moonlight encounters a controller on the Steam Deck, it does what every streaming client does — it translates the input into a standard virtual Xbox 360 gamepad and sends that to Sunshine on the PC. Your PC never sees a DualSense. It sees a generic XInput device.

Adaptive triggers? Gone — Xbox pads don't have trigger resistance. HD haptics? Replaced with basic rumble. Gyroscope? XInput doesn't support it. Touchpad? Doesn't exist on an Xbox controller.

```
DualSense --> Steam Deck --> Moonlight --> [XInput Translation] --> Sunshine --> Virtual Xbox Pad
                                                   ^
                                           Features die here.
```

This happens because Sunshine on Windows only supports Xbox 360 and DualShock 4 virtual controller emulation. Native DualSense emulation exists only on Linux, and even there adaptive triggers are blocked by SDL limitations.

## The Solution

Don't let Moonlight touch the controller. Forward the raw USB device over the network using VirtualHere, so Windows believes the DualSense is plugged directly into its own USB port.

```
DualSense --> Steam Deck --> VirtualHere USB/IP --> Network --> PC sees native USB DualSense
              Steam Deck --> Moonlight -----------------------------> Sunshine (video + audio only)
                                                                              |
                                                                          DSX on PC
                                                                      Adaptive Triggers  [works]
                                                                      HD Haptics         [works]
                                                                      Gyro               [works]
                                                                      Touchpad           [works]
```

Two parallel data paths. Moonlight handles pixels. VirtualHere handles the controller. They never interfere with each other.

---

## How It Works

```
+-----------------------------------------------------------------+
|                    ROOM B - Steam Deck                           |
|                                                                  |
|  +-----------+  USB-C  +--------------------+                    |
|  | DualSense |-------->| VirtualHere Server |                    |
|  +-----------+         +--------+-----------+                    |
|                                 | TCP :7575                      |
|  +-------------------+          |                                |
|  |    Moonlight      |          |                                |
|  | (video/audio only)|<---+     |                                |
|  +-------------------+    |     |                                |
|                           |     |                                |
+---------------------------+-----+--------------------------------+
                            |     |
                     +------+-----+------+
                     |   Network (LAN)   |
                     | or Tailscale VPN  |
                     +------+-----+------+
                            |     |
+---------------------------+-----+--------------------------------+
|                    ROOM A - Gaming PC                            |
|                           |     |                                |
|  +-------------------+    |     |                                |
|  |    Sunshine       |----+     |                                |
|  | (video/audio only)|          |                                |
|  | controller=off    |          |                                |
|  +-------------------+          |                                |
|                                 |                                |
|  +--------------------+ USB/IP  |                                |
|  | VirtualHere Client |<--------+                                |
|  +--------+-----------+                                          |
|           | appears as local USB                                 |
|  +--------v-----------+                                          |
|  |       DSX          |                                          |
|  | Adaptive Triggers  |                                          |
|  | HD Haptics         |                                          |
|  | Gyro + Touchpad    |                                          |
|  +--------+-----------+                                          |
|           |                                                      |
|  +--------v-----------+                                          |
|  |      Game          |                                          |
|  +--------------------+                                          |
+-----------------------------------------------------------------+
```

---

## Features

- **Adaptive Triggers** — per-game resistance profiles through DSX
- **HD Haptics** — precision haptic feedback, not generic rumble
- **Gyroscope** — full 6-axis motion passthrough
- **Touchpad** — native multi-touch input
- **Zero cost** — VirtualHere free tier covers exactly one USB device
- **Low latency** — USB/IP over LAN adds ~1-3 ms (imperceptible)
- **Tailscale-ready** — works over encrypted mesh VPN
- **No driver hacks** — VirtualHere ships properly signed Windows drivers
- **Survives SteamOS updates** — binary + restore script persist in /home/deck/
- **Auto-start on boot** — system service runs in Desktop Mode and Game Mode
- **Works with standard DualSense too** — not just the Edge

---

## What You'll Need

### Hardware

| Device | Notes |
|:-------|:------|
| Gaming PC | Windows 10 or 11 |
| Steam Deck | SteamOS — handheld, docked, or as a USB bridge |
| DualSense | Edge or standard — both work identically |
| USB-C cable | To connect the DualSense to the Steam Deck |
| Local network | Both devices on the same LAN, or Tailscale |

### Software

| Software | Role | Where | Link |
|:---------|:-----|:------|:-----|
| Sunshine | Game-stream host | PC | [LizardByte/Sunshine](https://github.com/LizardByte/Sunshine) |
| Moonlight | Game-stream client | Deck | [moonlight-stream.org](https://moonlight-stream.org/) |
| VirtualHere Server | USB/IP server | Deck | [virtualhere.com](https://www.virtualhere.com/usb_server_software) |
| VirtualHere Client | USB/IP client | PC | [virtualhere.com](https://www.virtualhere.com/usb_client_software) |
| DSX (DualSenseX) | Adaptive Triggers + Haptics | PC | [Steam](https://store.steampowered.com/app/1812620/DSX/) / [GitHub](https://github.com/Paliverse/DualSenseX) |
| Tailscale *(optional)* | Mesh VPN | Both | [tailscale.com](https://tailscale.com/) |

---

## The Research

Before landing on this approach, I tested or investigated every viable path.

| Approach | Latency | Cost | Complexity | Reliability | Full DS Features | SteamOS OK |
|:---------|:-------:|:----:|:----------:|:-----------:|:----------------:|:----------:|
| **VirtualHere (USB/IP)** | ~1-3 ms | Free | Medium | High | Yes | Yes |
| USB/IP open-source | ~1-3 ms | Free | High | Medium | Yes | Yes |
| Sunshine DS4 emulation | <1 ms | Free | Low | High | No | Yes |
| Sunshine DS5 (Linux only) | <1 ms | Free | Medium | Medium | No | N/A |
| DS5Dongle (RPi Pico 2W) | ~1 ms | $7-16 | Low | High | Yes | No |
| **PhantomSense** | ~2-4 ms | **Free** | Medium | High | Yes | Yes |

**Why VirtualHere won:** the free tier supports exactly one USB device, which is exactly what we need. Signed Windows drivers, auto-discovery, a single static binary on SteamOS, and years of production use. The $49 license is only for forwarding multiple devices simultaneously.

---

## Manual Setup

> [!TIP]
> If you used the [Quick Install](#quick-install) above, skip this section entirely.

### Phase 1 — VirtualHere Server on Steam Deck

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

### Phase 2 — VirtualHere Client on Windows PC

Download the [VirtualHere Windows Client](https://www.virtualhere.com/usb_client_software) and run it. The Deck should appear automatically within ~15 seconds.

If it doesn't (common with multi-router setups): right-click the top node, click "Specify Hubs...", click "Add", enter `<Steam_Deck_IP>:7575`.

### Phase 3 — Forward the DualSense

Expand the Steam Deck node. Right-click the DualSense, click "Use this device". Windows installs HID drivers automatically. You should see "In use by you".

Verify in Device Manager — look for a Sony HID entry under Human Interface Devices and a new audio device under Sound (DualSense haptics use audio channels).

### Phase 4 — DSX Setup

Install [DSX](https://store.steampowered.com/app/1812620/DSX/) from Steam. Install [ViGEmBus](https://github.com/nefarius/ViGEmBus/releases) (required) and [HidHide](https://github.com/nefarius/HidHide/releases) (optional, prevents double-input). Launch DSX — it should detect the DualSense as a wired USB controller.

Open the trigger test panel, apply a preset like Rigid or Pulse, and feel the adaptive triggers respond on the controller. If the triggers push back, PhantomSense is working.

### Phase 5 — Sunshine / Moonlight Config

This prevents double input (one pad from VirtualHere, one from Moonlight).

In Sunshine, open `https://localhost:47990`, go to Configuration > Input, set Controller to `disabled`. Or add this to `sunshine.conf`:

```ini
controller = disabled
```

Moonlight on the Deck just carries video and audio from this point.

### Phase 6 — Auto-Start on Boot

> [!TIP]
> The Quick Install script handles this automatically, including a restore script for SteamOS updates.

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

SteamOS updates can wipe `/etc/systemd/system/`. The binary in `/home/deck/` survives. Keep a backup script to recreate the service — or just use the Quick Install, which saves one at `~/phantomsense/restore-service.sh`.

---

## Your Gaming Session

Once everything is set up, each session looks like this:

1. Power on the Steam Deck. VirtualHere starts automatically.
2. Plug in the DualSense (or it's already plugged in). VirtualHere Client on the PC auto-attaches it.
3. DSX detects the controller. Adaptive triggers and haptics activate.
4. Open Moonlight on the Deck, connect to Sunshine, pick a game.
5. Play. Full DualSense, from the other room.

The DualSense is forwarded to the PC, so it won't control the Deck locally. Use the Deck's touchscreen or built-in controls to navigate Moonlight.

---

## Cost

| Item | Cost | Notes |
|:-----|-----:|:------|
| VirtualHere Server | $0 | Free tier — 1 USB device |
| VirtualHere Client | $0 | Bundled |
| DSX | $0 | Free version on Steam |
| Moonlight | $0 | Open source |
| Sunshine | $0 | Open source |
| Tailscale | $0 | Free for personal use |
| **Total** | **$0** | |

VirtualHere's free tier has no time limit for one device. The $49 license is only for multiple devices. DSX's paid DLC (~$4.99) unlocks extra haptic modes but the free version covers the essentials.

---

## Fallback — Open-Source USB/IP

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

### Windows PC

Use [usbip-win2](https://github.com/vadimgrn/usbip-win2) — actively maintained with WHLK-certified drivers.

### Trade-offs

| | USB/IP (open source) | VirtualHere |
|:--|:--:|:--:|
| Cost | Free | Free (1 device) |
| Stability | Occasional BSOD | Very stable |
| SteamOS persistence | Wiped on updates | Survives |
| Complexity | High | Medium |
| Auto-discovery | Manual | Automatic |

</details>

---

## Network Topology

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

If auto-discovery doesn't work, the two routers probably put the devices on different subnets. Add the hub manually or use Tailscale.

---

## Performance

| Component | Added Latency | Notes |
|:----------|:------------:|:------|
| VirtualHere USB/IP (LAN) | ~1-3 ms | TCP encapsulation, negligible |
| Moonlight / Sunshine video | ~5-15 ms | Depends on encoder and network |
| DSX processing | <1 ms | Local, instant |
| **Total controller overhead** | **~1-3 ms** | Imperceptible vs. direct USB |

In blind testing, I could not tell the difference between the DualSense plugged directly into the PC and forwarded via PhantomSense over Wi-Fi. The dominant latency is always the video stream, never the controller.

---

## Troubleshooting

<details>
<summary>VirtualHere Client shows nothing</summary>

- Server not running — check `sudo systemctl status phantomsense`
- Different subnets — manually add the hub: `<Deck_IP>:7575`
- Firewall — `sudo iptables -A INPUT -p tcp --dport 7575 -j ACCEPT`

</details>

<details>
<summary>DSX does not detect the DualSense</summary>

- VirtualHere must say "In use by you"
- Check Device Manager for a Sony HID entry
- Unplug and re-plug the USB-C cable, re-attach in VirtualHere
- Restart DSX

</details>

<details>
<summary>Double input / ghost controller</summary>

- Set `controller = disabled` in Sunshine config
- Whitelist only DSX in HidHide
- Confirm Moonlight isn't forwarding a virtual pad

</details>

<details>
<summary>HD Haptics don't work</summary>

- Haptics use audio channels (4-channel device: 2 for headphone jack, 2 for haptic actuators)
- Check Windows Sound Settings for a DualSense audio device
- Make sure the haptics channels aren't muted

</details>

<details>
<summary>Service file wiped after SteamOS update</summary>

- The binary survives in `/home/deck/` — only the systemd unit is wiped
- Quick Install users: `sudo ~/phantomsense/restore-service.sh`
- Manual users: recreate the service file from Phase 6

</details>

<details>
<summary>Noticeable input latency</summary>

- Use wired Ethernet instead of Wi-Fi
- In VirtualHere Client, right-click the hub and enable "Optimize for Interactive (Low Latency)"
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

No. USB/IP detaches it from the Deck. Use the Deck's own controls for Moonlight.

</details>

<details>
<summary>Will VirtualHere's free tier always support one device?</summary>

As of May 2026, yes. No trial expiry. Multi-device requires the $49 license.

</details>

<details>
<summary>Does this work over the internet?</summary>

Yes, with a VPN like Tailscale. LAN is recommended for gaming.

</details>

<details>
<summary>What about anti-cheat?</summary>

Some engines may flag VirtualHere's virtual USB hub driver. Best for single-player and co-op.

</details>

<details>
<summary>Do DSX game-specific profiles work?</summary>

Yes. DSX sees a normal wired USB DualSense. Every profile and trigger config works.

</details>

---

## Roadmap

- [x] ~~One-click setup script for Steam Deck~~
- [x] ~~One-click setup script for Windows PC~~
- [x] ~~Double-click .bat launcher for Windows~~
- [ ] Decky Loader plugin for Game Mode integration
- [ ] Wired vs. Wi-Fi latency benchmarks
- [ ] Tailscale WAN configuration guide
- [ ] DualSense back-button and stick-module testing
- [ ] Track Sunshine DS5 emulation — [LizardByte #652](https://github.com/orgs/LizardByte/discussions/652)
- [ ] Video walkthrough
- [ ] Game compatibility matrix

---

## Contributing

Contributions are welcome — bug reports, doc improvements, script enhancements, game compatibility reports, alternative network configs. Open an [issue](https://github.com/AarveeGill/Phantom-Sense/issues) or submit a [pull request](https://github.com/AarveeGill/Phantom-Sense/pulls).

---

## References & Credits

| Project | Author | Role |
|:--------|:-------|:-----|
| [VirtualHere](https://www.virtualhere.com/) | VirtualHere Pty. Ltd. | USB/IP backbone |
| [DSX / DualSenseX](https://github.com/Paliverse/DualSenseX) | Paliverse | Adaptive triggers + haptics |
| [Sunshine](https://github.com/LizardByte/Sunshine) | LizardByte | Open-source stream host |
| [Moonlight](https://github.com/moonlight-stream) | moonlight-stream | Stream client |
| [DS5Dongle](https://github.com/awalol/DS5Dongle) | awalol | Validated wired DS = full features |
| [usbip-win2](https://github.com/vadimgrn/usbip-win2) | vadimgrn | Open-source USB/IP client |
| [Steam Deck USB/IP](https://github.com/kalvinarts/steam-deck-usbip) | kalvinarts | Pioneered USB/IP on SteamOS |
| [Valve](https://www.valvesoftware.com/) | Valve Corporation | Creating the Steam Deck |

And every forum poster, Reddit commenter, and GitHub contributor whose scattered fragments of knowledge helped piece this together.

---

## License

MIT License — Copyright (c) 2026 Rajvinder Singh

<details>
<summary>Full text</summary>

```
MIT License

Copyright (c) 2026 Rajvinder Singh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

</details>

---

<div align="center">

**Rajvinder Singh**

*Your PC sees a DualSense that isn't there. That's PhantomSense.*

If this saved you time or inspired your setup, a star helps others find it.

</div>
