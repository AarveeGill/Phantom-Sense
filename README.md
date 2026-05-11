<!--
 PhantomSense, Your PC sees a DualSense that isn't there.
 github.com/AarveeGill/phantom-sense
 -->
 
 <div align="center">
 
 # PhantomSense
 
 ### Your PC sees a DualSense that isn't there.
 
 <br>
 
 [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
 [![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20SteamOS-lightgrey?style=for-the-badge&logo=steam)](https://store.steampowered.com/steamdeck)
 [![Maintained](https://img.shields.io/badge/Maintained-Yes-green?style=for-the-badge)](https://github.com/AarveeGill/phantom-sense/commits/main)
 [![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge)](https://github.com/AarveeGill/phantom-sense/pulls)
 [![Stars](https://img.shields.io/github/stars/AarveeGill/phantom-sense?style=for-the-badge)](https://github.com/AarveeGill/phantom-sense/stargazers)
 [![Issues](https://img.shields.io/github/issues/AarveeGill/phantom-sense?style=for-the-badge)](https://github.com/AarveeGill/phantom-sense/issues)
 
 <br>
 
 **PhantomSense** lets you connect a **DualSense** to a **Steam Deck** in another room,
 stream your PC games through **Moonlight / Sunshine**, and still get
 **Adaptive Triggers, HD Haptics, Gyro & Touchpad**, as if the controller
 were plugged directly into the PC.
 
 **The total cost is zero dollars.**
 
 <br>
 
 > *"Built this because I refused to accept that a $200 pro controller*
 > *should feel like a $20 gamepad just because it's in another room."*
 
 <br>
 
 <!-- DEMO, replace with your own GIF or video link
 ![PhantomSense Demo](assets/demo.gif)
 -->
 
 *If PhantomSense helped you, a star helps others find it.*
 
 </div>
 
 ---
 
 ## Table of Contents
 
 - [Why PhantomSense?](#why-phantomsense)
 - [How It Works](#how-it-works)
 - [Features](#features)
 - [What You'll Need](#what-youll-need)
 - [The Research](#the-research)
 - [Getting Started](#getting-started)
 - [Phase 1, VirtualHere Server on Steam Deck](#phase-1--virtualhere-server-on-steam-deck)
 - [Phase 2, VirtualHere Client on Windows PC](#phase-2--virtualhere-client-on-windows-pc)
 - [Phase 3, Forward the DualSense](#phase-3--forward-the-dualsense)
 - [Phase 4, DSX Setup](#phase-4--dsx-setup)
 - [Phase 5, Sunshine / Moonlight Config](#phase-5--sunshine--moonlight-config)
 - [Phase 6, Auto-Start on Boot](#phase-6--auto-start-on-boot)
 - [Your Gaming Session](#your-gaming-session)
 - [Cost](#cost)
 - [Fallback, Open-Source USB/IP](#fallback--open-source-usbip)
 - [Network Topology](#network-topology)
 - [Performance](#performance)
 - [Troubleshooting](#troubleshooting)
 - [FAQ](#faq)
 - [Roadmap](#roadmap)
 - [Contributing](#contributing)
 - [References & Credits](#references--credits)
 - [License](#license)
 - [Author](#author)
 
 ---
 
 ## Why PhantomSense?
 
 Here is the scenario.
 
 You own a **DualSense**, Sony's flagship PS5 controller with adaptive triggers that simulate bow tension, gear resistance, and brake pressure. HD haptics that let you feel rain droplets. A precision gyroscope. A multi-touch trackpad. You paid a premium because these features matter.
 
 You also own a **Steam Deck** and a **Gaming PC**. The PC lives in one room. You game from another room using the Steam Deck as a thin client, streaming via **Moonlight to Sunshine**. The DualSense is plugged into the Deck over USB-C.
 
 Everything should just work. But it doesn't.
 
 ### The Problem
 
 When Moonlight encounters your controller on the Steam Deck, it does what every game-streaming client does, it **translates** the input into a standard **virtual Xbox 360 gamepad** and sends that to Sunshine on the PC. Your PC never sees a DualSense. It sees a generic XInput pad. Every premium feature is silently discarded:
 
 | Feature | What Happens |
 |:--------|:-------------|
 | Adaptive Triggers | Lost, virtual Xbox pad has no concept of trigger resistance |
 | HD Haptics | Lost, replaced with basic rumble at best |
 | Gyroscope | Lost, XInput has no gyro support |
 | Touchpad | Lost, no touchpad on an Xbox controller |
 | Basic buttons & sticks | Works, as a generic gamepad |
 
 In short, Moonlight turns your $200 controller into a $20 one.
 
 This happens because Sunshine on Windows only supports **Xbox 360** and **DualShock 4 (DS4)** virtual controller emulation. Native DualSense (DS5) emulation exists only on Linux and even there, adaptive triggers are blocked by SDL limitations.
 
 ```
 WHAT MOONLIGHT DOES (the problem):
 
 DualSense --> Steam Deck --> Moonlight --> [XInput Translation] --> Sunshine --> Virtual Xbox Pad
 ^
 Features die here.
 ```
 
 ### The Insight
 
 What if we **don't let Moonlight touch the controller at all**?
 
 What if we forward the **raw USB device** over the network to the PC, bypassing every translation layer, so that Windows believes the DualSense is plugged directly into its own USB port?
 
 Then DSX (DualSenseX) on the PC would detect a real, wired DualSense. Adaptive triggers would work. HD haptics would work. Gyro, touchpad, everything. The controller becomes a **phantom**, physically in one room, logically in another.
 
 That's PhantomSense.
 
 ```
 WHAT PHANTOMSENSE DOES (the solution):
 
 DualSense --> Steam Deck --> VirtualHere USB/IP --> Network --> PC sees native USB DualSense
 Steam Deck --> Moonlight ----------------------------------------> Sunshine (video + audio only)
 |
 DSX on PC
 - Adaptive Triggers [Yes]
 - HD Haptics [Yes]
 - Gyro [Yes]
 - Touchpad [Yes]
 ```
 
 Two parallel data paths. Moonlight handles the pixels. VirtualHere handles the controller. They never interfere with each other.
 
 ---
 
 ## How It Works
 
 ```
 +-------------------------------------------------------------------+
 | ROOM B - Steam Deck |
 | |
 | +---------------+ USB-C +----------------------+ |
 | | DualSense |---------->| VirtualHere Server | |
 | | Edge | | (vhusbdx86_64) | |
 | +---------------+ +----------+-----------+ |
 | | TCP :7575 |
 | +-----------------------+ | |
 | | Moonlight | | |
 | | (video / audio only) |<-----+ | |
 | +-----------------------+ | | |
 | | | |
 +-----------------------------------+------+------------------------+
 | |
 +-----+------+-----+
 | Network (LAN) |
 | or Tailscale VPN |
 +-----+------+-----+
 | |
 +-----------------------------------+------+------------------------+
 | ROOM A - Gaming PC |
 | | | |
 | +-----------------------+ | | |
 | | Sunshine |------+ | |
 | | (video / audio only) | | |
 | | controller = disabled| | |
 | +-----------------------+ | |
 | | |
 | +----------------------+ USB/IP | |
 | | VirtualHere Client |<-------------+ |
 | +----------+-----------+ |
 | | appears as local USB |
 | +----------v-----------+ |
 | | DSX | |
 | | Adaptive Triggers | |
 | | HD Haptics | |
 | | Gyro | |
 | | Touchpad | |
 | +----------+-----------+ |
 | | |
 | +----------v-----------+ |
 | | Game | |
 | +----------------------+ |
 +-------------------------------------------------------------------+
 ```
 
 ---
 
 ## Features
 
 - **Adaptive Triggers**, per-game resistance profiles through DSX
 - **HD Haptics**, precision haptic feedback, not generic rumble
 - **Gyroscope**, full 6-axis motion passthrough
 - **Touchpad**, native multi-touch input
 - **Zero cost**, VirtualHere free tier covers exactly one USB device
 - **Low latency**, USB/IP over LAN adds ~1-3 ms (imperceptible)
 - **Tailscale-ready**, works over encrypted mesh VPN
 - **No driver hacks**, VirtualHere ships properly signed Windows drivers
 - **Survives SteamOS updates**, binary lives in `/home/deck/`
 - **Auto-start capable**, optional systemd service starts on boot
 - **Works with standard DualSense too**, not just the Edge
 
 ---
 
 ## What You'll Need
 
 ### Hardware
 
 | Device | Notes |
 |:-------|:------|
 | **Gaming PC** | Windows 10 / 11, your main rig that runs games natively |
 | **Steam Deck** | SteamOS, used as a streaming client in another room |
 | **DualSense** | Sony's pro controller (standard DualSense also works) |
 | **USB-C cable** | To connect the DualSense to the Steam Deck |
 | **Local network** | Both devices on the same LAN (or Tailscale) |
 
 ### Software
 
 | Software | Role | Where | Link |
 |:---------|:-----|:------|:-----|
 | **Sunshine** | Game-stream host | PC | [LizardByte/Sunshine](https://github.com/LizardByte/Sunshine) |
 | **Moonlight** | Game-stream client | Steam Deck | [moonlight-stream.org](https://moonlight-stream.org/) |
 | **VirtualHere Server** | USB/IP server | Steam Deck | [virtualhere.com](https://www.virtualhere.com/usb_server_software) |
 | **VirtualHere Client** | USB/IP client | PC | [virtualhere.com](https://www.virtualhere.com/usb_client_software) |
 | **DSX (DualSenseX)** | Enables Adaptive Triggers + Haptics | PC | [Steam](https://store.steampowered.com/app/1812620/DSX/) / [GitHub](https://github.com/Paliverse/DualSenseX) |
 | **Tailscale** *(optional)* | Mesh VPN | Both | [tailscale.com](https://tailscale.com/) |
 
 ---
 
 ## The Research
 
 Before landing on this approach, I tested or deeply investigated every viable path. Here is the full picture:
 
 | Approach | Latency | Cost | Complexity | Reliability | Full DS Features | SteamOS OK |
 |:---------|:--------|:-----|:-----------|:------------|:----------------:|:----------:|
 | **VirtualHere (USB/IP)** | ~1-3 ms | **Free** | Medium | High | Yes | Yes |
 | USB/IP open-source (`usbip` + `usbip-win2`) | ~1-3 ms | Free | High | Medium | Yes | Yes |
 | Sunshine DS4 emulation | <1 ms | Free | Low | High | No | Yes |
 | Sunshine DS5 emulation (Linux host only) | <1 ms | Free | Medium | Medium | No (SDL blocks triggers) | N/A |
 | DSX remote / network mode |, |, |, |, | Does not exist |, |
 | DS5Dongle (Raspberry Pi Pico 2W) | ~1 ms | $7-16 | Low | High | Yes | No (needs PC USB) |
 | **PhantomSense (VH + Moonlight)** | ~2-4 ms | **Free** | Medium | High | Yes | Yes |
 
 > **Why VirtualHere won:** Its free tier supports **exactly one USB device**, which is exactly what we need. Signed Windows drivers, auto-discovery, a single static binary on SteamOS, and years of production use. The $49 license is only required if you forward multiple devices simultaneously.
 
 ---
 
 ## Getting Started
 
 ### Phase 1, VirtualHere Server on Steam Deck
 
 Switch the Steam Deck to **Desktop Mode** (`Steam Menu > Power > Switch to Desktop`).
 
 Open **Konsole** from the application menu, then run:
 
 ```bash
 # set a password if you haven't already
 passwd
 
 # create a home for virtualhere
 mkdir -p ~/Documents/virtualhere
 cd ~/Documents/virtualhere
 
 # download the server (single static binary, no install needed)
 wget https://www.virtualhere.com/sites/default/files/usbserver/vhusbdx86_64
 chmod +x vhusbdx86_64
 
 # plug the DualSense into the Deck via USB-C, then start the server
 sudo ./vhusbdx86_64
 ```
 
 You should see:
 
 ```
 VirtualHere USB Server x86_64 running...
 ```
 
 > **Warning:** Keep this terminal open. Closing it kills the server. For auto-start on boot, see [Phase 6](#phase-6--auto-start-on-boot).
 
 > **Tip:** The first run creates a `config.ini` in the same folder, that is expected.
 
 ---
 
 ### Phase 2, VirtualHere Client on Windows PC
 
 1. Download the [VirtualHere Windows Client](https://www.virtualhere.com/usb_client_software) and run it
 2. If both devices share a subnet, the Steam Deck appears automatically within 10-15 seconds
 
 **If auto-discovery doesn't find it** (common with multi-router setups):
 
 1. Right-click **"VirtualHere Client"** (the top node in the tree)
 2. Click **"Specify Hubs..."** > **"Add"**
 3. Enter `<Steam_Deck_IP>:7575` and click **OK**
 
 > **Tip:** Find the Deck's IP by running `ip addr` in Konsole, look for the address under `wlan0` (Wi-Fi) or `eth0` (wired).
 
 ---
 
 ### Phase 3, Forward the DualSense
 
 1. Expand the Steam Deck node in the tree view
 2. **Right-click** the DualSense > **"Use this device"**
 3. Windows installs HID drivers automatically
 4. Status changes to **"In use by you"**
 
 **Verify it worked:**
 
 | Check | Where |
 |:------|:------|
 | Sony HID device listed | Device Manager > Human Interface Devices |
 | New audio device appeared | Settings > Sound (DualSense haptics use audio channels) |
 | DSX detects the controller | Launch DSX (next phase) |
 
 ---
 
 ### Phase 4, DSX Setup
 
 1. Install **[DSX](https://store.steampowered.com/app/1812620/DSX/)** from Steam (free version works; paid DLC unlocks extra features)
 
 2. Install the required drivers:
 - [**ViGEmBus**](https://github.com/nefarius/ViGEmBus/releases), virtual gamepad emulation
 - [**HidHide**](https://github.com/nefarius/HidHide/releases) *(optional)*, prevents double-input issues
 
 3. Launch DSX, it should detect the DualSense as a **wired USB controller**
 
 4. Open the **trigger test** panel, apply a preset (Rigid, Pulse, etc.), and **feel the adaptive triggers respond** on the controller in the other room
 
 This is the moment. If the triggers push back against your fingers, **PhantomSense is working.**
 
 ---
 
 ### Phase 5, Sunshine / Moonlight Config
 
 This step prevents **double input** (one gamepad from VirtualHere + one virtual gamepad from Moonlight).
 
 **Sunshine (on the PC):**
 
 Open the web UI at `https://localhost:47990` > **Configuration > Input** > set **Controller** to `disabled`, then save and restart Sunshine.
 
 Or edit `sunshine.conf` directly:
 
 ```ini
 controller = disabled
 ```
 
 **Moonlight (on the Steam Deck):**
 
 Launch Moonlight, connect to Sunshine, and stream as usual. It now carries **video and audio only**, no controller data.
 
 ---
 
 ### Phase 6, Auto-Start on Boot
 
 To avoid opening Konsole every time, create a **systemd service** on the Deck:
 
 ```bash
 sudo nano /etc/systemd/system/virtualhere.service
 ```
 
 Paste:
 
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
 
 Enable and start:
 
 ```bash
 sudo systemctl daemon-reload
 sudo systemctl enable virtualhere.service
 sudo systemctl start virtualhere.service
 ```
 
 Verify:
 
 ```bash
 sudo systemctl status virtualhere.service
 ```
 
 > **Warning:** SteamOS updates can wipe `/etc/systemd/system/`. The binary in `/home/deck/` is safe, but you may need to recreate the service file. Keep a backup script:
 
 <details>
 <summary>Backup script, <code>setup-service.sh</code></summary>
 
 Save to `~/Documents/virtualhere/setup-service.sh`:
 
 ```bash
 #!/bin/bash
 # PhantomSense, restore VirtualHere systemd service after SteamOS update
 
 cat << 'EOF' | sudo tee /etc/systemd/system/virtualhere.service
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
 EOF
 
 sudo systemctl daemon-reload
 sudo systemctl enable virtualhere.service
 sudo systemctl start virtualhere.service
 echo "VirtualHere service restored and running."
 ```
 
 Make it executable:
 
 ```bash
 chmod +x ~/Documents/virtualhere/setup-service.sh
 ```
 
 After any SteamOS update, run:
 
 ```bash
 sudo ~/Documents/virtualhere/setup-service.sh
 ```
 
 </details>
 
 ---
 
 ## Your Gaming Session
 
 Once everything is set up, each session is effortless:
 
 ```
 1. Power on the Steam Deck
 VirtualHere server starts automatically (systemd)
 
 2. DualSense is already plugged in (or plug it in now)
 VirtualHere Client on PC auto-connects and attaches it
 
 3. DSX on the PC detects the controller
 Adaptive triggers and haptics activate
 
 4. Launch Moonlight on the Deck > connect to Sunshine > pick your game
 
 5. Play.
 Full DualSense experience, from the other room.
 ```
 
 > **Tip:** The DualSense is forwarded to the PC, so it won't control the Deck locally. Use the **Steam Deck's touchscreen** or **built-in sticks and buttons** to navigate Moonlight. The Deck's own controls are separate and are never forwarded.
 
 ---
 
 ## Cost
 
 | Item | Cost | Notes |
 |:-----|-----:|:------|
 | VirtualHere Server | **$0** | Free tier, 1 USB device |
 | VirtualHere Client | **$0** | Bundled with server |
 | DSX (DualSenseX) | **$0** | Free version on Steam |
 | Moonlight | **$0** | Open source |
 | Sunshine | **$0** | Open source |
 | Tailscale | **$0** | Free for personal use |
 | **Total** | **$0** | |
 
 > VirtualHere's free tier has **no time limit** for a single device. The $49 one-time license is only needed for forwarding multiple USB devices simultaneously. For PhantomSense, one DualSense, **you never need to pay.**
 >
 > DSX optionally offers a paid DLC (~$4.99) for advanced haptic modes and game mods. The free version covers the essentials.
 
 ---
 
 ## Fallback, Open-Source USB/IP
 
 If you prefer a fully open-source stack without VirtualHere, you can use the Linux kernel's built-in `usbip` and the Windows client **usbip-win2**.
 
 <details>
 <summary>Click to expand the open-source setup guide</summary>
 
 ### Steam Deck (server)
 
 ```bash
 # enable developer mode (allows pacman)
 sudo steamos-devmode enable
 
 # install usbip tools
 sudo pacman -S usbip
 
 # load kernel modules
 sudo modprobe usbip-core usbip-host
 
 # start the daemon
 sudo usbipd -D
 
 # list connected USB devices
 usbip list -l
 
 # bind the DualSense (replace X-Y with actual bus ID)
 sudo usbip bind -b X-Y
 ```
 
 ### Windows PC (client)
 
 Use **[usbip-win2](https://github.com/vadimgrn/usbip-win2)** by vadimgrn, actively maintained with WHLK-certified drivers (v0.9.7.8+).
 
 1. Download the latest release from [GitHub Releases](https://github.com/vadimgrn/usbip-win2/releases)
 2. Install the drivers
 3. Use the GUI to connect to the Deck's IP and attach the DualSense
 
 ### Trade-offs
 
 | Aspect | USB/IP (open source) | VirtualHere |
 |:-------|:---------------------|:------------|
 | Cost | Free | Free (1 device) |
 | Driver signing | WHLK certified (recent) | Properly signed |
 | Stability | Occasional BSOD on disconnect | Very stable |
 | SteamOS persistence | Wiped on OS updates | Binary survives in /home |
 | Setup complexity | High | Medium |
 | Auto-discovery | Manual | Automatic |
 
 </details>
 
 ---
 
 ## Network Topology
 
 This is the physical network layout PhantomSense was designed and tested on:
 
 ```
 +------------------+
 | Gaming PC |
 | (Windows) |
 | |
 | - Sunshine |
 | - VH Client |
 | - DSX |
 +--------+---------+
 | Wired Ethernet
 v
 +------------------+
 | Router 1 |
 | (Primary) |
 +--------+---------+
 | Wired Ethernet
 v
 +------------------+
 | Router 2 |
 | (Secondary) |
 +--------+---------+
 | Wi-Fi or Wired
 v
 +------------------+
 | Steam Deck |
 | (SteamOS) |
 | |
 | - VH Server |
 | - Moonlight |
 | - DualSense <----- USB-C
 +------------------+
 
 - - - - - - - - - - -
 Tailscale mesh VPN overlay
 (optional, encrypted, traverses both routers cleanly)
 ```
 
 > **Tip:** If auto-discovery fails, the two routers likely place devices on different subnets. Manually add the hub in VirtualHere Client using the Deck's IP, or route traffic through Tailscale for a flat address space.
 
 ---
 
 ## Performance
 
 | Component | Added Latency | Notes |
 |:----------|:-------------|:------|
 | VirtualHere USB/IP (LAN) | ~1-3 ms | TCP encapsulation; negligible |
 | Moonlight / Sunshine video | ~5-15 ms | Depends on encoder, resolution, network |
 | DSX processing | <1 ms | Local software, instant |
 | **Total additional input lag** | **~1-3 ms** | vs. DualSense plugged directly into PC |
 
 > In blind testing, I could not distinguish between the DualSense plugged directly into the PC and the DualSense forwarded via PhantomSense over Wi-Fi. The dominant latency in this setup is always the video stream, never the controller.
 
 ---
 
 ## Troubleshooting
 
 <details>
 <summary><b>VirtualHere Client shows nothing under the top node</b></summary>
 
 - **Server not running:** Confirm with `sudo systemctl status virtualhere.service` or check the Konsole output.
 - **Different subnets:** Two routers often mean two subnets. Manually add: right-click > *Specify Hubs...* > `<Deck_IP>:7575`.
 - **Firewall:** Open TCP port 7575 on the Deck: `sudo iptables -A INPUT -p tcp --dport 7575 -j ACCEPT`.
 
 </details>
 
 <details>
 <summary><b>DSX does not detect the DualSense</b></summary>
 
 - Ensure VirtualHere status says **"In use by you"**.
 - Check Device Manager for a Sony HID entry under *Human Interface Devices*.
 - Unplug and re-plug the USB-C cable on the Deck, then re-use the device in VirtualHere.
 - Restart DSX after the device is attached.
 
 </details>
 
 <details>
 <summary><b>Double input / ghost controller</b></summary>
 
 - Set `controller = disabled` in Sunshine's config.
 - If you use HidHide, whitelist only DSX.
 - Confirm Moonlight is not forwarding its own virtual pad.
 
 </details>
 
 <details>
 <summary><b>HD Haptics do not work</b></summary>
 
 - DualSense HD haptics are delivered through **audio channels** (4-channel device: 2 for the 3.5 mm jack, 2 for haptic actuators).
 - Check **Windows Sound Settings** for a new DualSense audio device after VirtualHere attaches it.
 - Ensure the haptics channels are not muted.
 
 </details>
 
 <details>
 <summary><b>Service file wiped after SteamOS update</b></summary>
 
 - The binary in `/home/deck/Documents/virtualhere/` survives updates.
 - Only the systemd unit in `/etc/systemd/system/` is affected.
 - Re-run the backup script: `sudo ~/Documents/virtualhere/setup-service.sh`
 
 </details>
 
 <details>
 <summary><b>Noticeable input latency</b></summary>
 
 - Use a **wired Ethernet** connection from Steam Deck to Router 2 instead of Wi-Fi.
 - In VirtualHere Client: right-click the hub > *Properties* > enable **"Optimize for Interactive (Low Latency)"**.
 - Try Tailscale, it sometimes offers a more direct route than double-NAT.
 
 </details>
 
 ---
 
 ## FAQ
 
 **Does PhantomSense work with the standard DualSense (non-Edge)?**
 Yes. Both models share the same HID protocol. Every step in this guide applies equally.
 
 **Can I use the DualSense on the Steam Deck and forward it to the PC at the same time?**
 No. USB/IP detaches the device from the local host. While forwarded, the Deck cannot see the controller. Navigate Moonlight with the Deck's own controls or touchscreen.
 
 **Will VirtualHere's free tier always support one device?**
 As of May 2026, yes. There is no trial expiry for a single device. Multi-device forwarding requires the $49 licence.
 
 **Does this work over the internet?**
 Yes, provided both devices share a VPN (Tailscale is ideal). Latency depends on your connection; LAN is recommended for gaming.
 
 **What about anti-cheat?**
 Some aggressive anti-cheat engines may flag VirtualHere's virtual USB hub driver. PhantomSense is best suited for single-player and cooperative titles. Always test in a non-competitive context first.
 
 **Why not just run a long USB cable to the PC?**
 Because I value comfort, living-room gaming, and not drilling holes through walls. The whole point of a streaming setup is wireless freedom.
 
 **Can I still use DSX game-specific mods and profiles?**
 Absolutely. As far as DSX is concerned, the DualSense is a perfectly normal wired USB controller. Every mod, profile, and per-game trigger configuration works exactly as documented by DSX.
 
 ---
 
 ## Roadmap
 
 - [ ] One-click setup script for Steam Deck (download, install, systemd, single command)
 - [ ] Decky Loader plugin for Game Mode integration
 - [ ] Wired vs. Wi-Fi latency benchmarks with charts
 - [ ] Tailscale-specific WAN configuration guide
 - [ ] DualSense back-button and stick-module testing
 - [ ] Track Sunshine Windows DS5 emulation, [LizardByte #652](https://github.com/orgs/LizardByte/discussions/652)
 - [ ] Video walkthrough / demo
 - [ ] Game compatibility matrix (which titles support DualSense features)
 
 ---
 
 ## Contributing
 
 Contributions are welcome. Whether it's:
 
 - **Bug reports**, hit a snag? Open an issue
 - **Docs**, better wording, translations, typo fixes
 - **Scripts & automation**, improve the setup flow
 - **Game reports**, tested a title with DualSense features? Share results
 - **Network configs**, alternative topologies, VPN setups
 
 Please open an [issue](https://github.com/AarveeGill/phantom-sense/issues) or submit a [pull request](https://github.com/AarveeGill/phantom-sense/pulls).
 
 ---
 
 ## References & Credits
 
 | Project | Author / Org | Role in PhantomSense |
 |:--------|:-------------|:---------------------|
 | [VirtualHere](https://www.virtualhere.com/) | Michael (VirtualHere Pty. Ltd.) | USB/IP server and client, the backbone |
 | [DSX / DualSenseX](https://github.com/Paliverse/DualSenseX) | Paliverse | Unlocks adaptive triggers and haptics on PC |
 | [Sunshine](https://github.com/LizardByte/Sunshine) | LizardByte | Open-source game-streaming host |
 | [Moonlight](https://github.com/moonlight-stream) | moonlight-stream | Game-streaming client |
 | [DS5Dongle](https://github.com/awalol/DS5Dongle) | awalol | Validated that a "wired" DualSense = full PC features |
 | [usbip-win2](https://github.com/vadimgrn/usbip-win2) | vadimgrn | Open-source Windows USB/IP client |
 | [Steam Deck USB/IP scripts](https://github.com/kalvinarts/steam-deck-usbip) | kalvinarts | Pioneered USB/IP on SteamOS |
 | [Valve](https://www.valvesoftware.com/) | Valve Corporation | For creating the Steam Deck |
 
 And every forum poster, Reddit commenter, and GitHub contributor whose scattered fragments of knowledge helped me piece this together.
 
 ---
 
 ## License
 
 PhantomSense is released under the **MIT License**.
 
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
 
 ---
 
 ## Star History
 
 <!-- Uncomment after your repo gets some stars:
 [![Star History Chart](https://api.star-history.com/svg?repos=AarveeGill/phantom-sense&type=Date)](https://star-history.com/#AarveeGill/phantom-sense&Date)
 -->
 
 *Star history chart will appear once the project picks up traction.*
 
 ---
 
 <div align="center">
 
 ## Author
 
 **Rajvinder Singh**
 
 <!-- Replace with your actual links:
 [![GitHub](https://img.shields.io/badge/GitHub-YOUR__USERNAME-181717?style=for-the-badge&logo=github)](https://github.com/AarveeGill)
 [![LinkedIn](https://img.shields.io/badge/LinkedIn-Rajvinder_Singh-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/YOUR_LINKEDIN)
 -->
 
 *Your PC sees a DualSense that isn't there. That's PhantomSense.*
 
 ---
 
 **If this saved you time or inspired your own setup, a star helps others find it.**
 
 </div>
 
 
