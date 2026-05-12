#!/bin/bash
# ============================================================================
# PhantomSense Deck Installer v1.2.0
# https://github.com/AarveeGill/Phantom-Sense
#
# One-command installer for Steam Deck (SteamOS)
# Installs VirtualHere USB Server as a persistent system service
#
# Usage:
# curl -sL https://raw.githubusercontent.com/AarveeGill/Phantom-Sense/main/install-phantomsense-deck.sh | bash
#
# Or download and run:
# ./install-phantomsense-deck.sh Install PhantomSense
# ./install-phantomsense-deck.sh --status Check installation status
# ./install-phantomsense-deck.sh --uninstall Remove PhantomSense
# ./install-phantomsense-deck.sh --help Show help
#
# Why a system service?
# VirtualHere needs root access to control USB devices. A system service
# runs as root and starts at boot in BOTH Desktop Mode and Game Mode.
#
# SteamOS updates:
# Updates can wipe /etc/systemd/system/. The binary and a restore script
# are saved in /home/deck/phantomsense/ (which survives updates).
# After an update, run: sudo ~/phantomsense/restore-service.sh
# ============================================================================

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────

PHANTOMSENSE_VERSION="1.2.0"
INSTALL_DIR="$HOME/phantomsense"
BINARY_NAME="vhusbdx86_64"
BINARY_URL="https://www.virtualhere.com/sites/default/files/usbserver/vhusbdx86_64"
SERVICE_NAME="phantomsense"
SYSTEM_SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
USER_SERVICE_DIR="$HOME/.config/systemd/user"
USER_SERVICE_FILE="$USER_SERVICE_DIR/$SERVICE_NAME.service"
RESTORE_SCRIPT="$INSTALL_DIR/restore-service.sh"
DESKTOP_SHORTCUT="$HOME/Desktop/PhantomSense.desktop"

# ── Colors ─────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Logging ────────────────────────────────────────────────────────────────

info() { echo -e "${CYAN}[INFO]${NC} $1"; }
ok() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "\n${BOLD}--- $1 ---${NC}"; }

# ── Banner ─────────────────────────────────────────────────────────────────

banner() {
 echo ""
 echo -e "${BOLD} PhantomSense Deck Installer v${PHANTOMSENSE_VERSION}${NC}"
 echo " Your PC sees a DualSense that isn't there."
 echo " https://github.com/AarveeGill/Phantom-Sense"
 echo ""
}

# ── Help ───────────────────────────────────────────────────────────────────

show_help() {
 banner
 echo "Usage:"
 echo " ./install-phantomsense-deck.sh Install PhantomSense"
 echo " ./install-phantomsense-deck.sh --status Check installation status"
 echo " ./install-phantomsense-deck.sh --uninstall Remove PhantomSense"
 echo " ./install-phantomsense-deck.sh --force Reinstall (re-download binary)"
 echo " ./install-phantomsense-deck.sh --help Show this help"
 echo ""
 echo "Or install directly with one command:"
 echo " curl -sL https://raw.githubusercontent.com/AarveeGill/Phantom-Sense/main/install-phantomsense-deck.sh | bash"
 echo ""
 echo "What this script does:"
 echo " 1. Downloads VirtualHere USB Server binary"
 echo " 2. Creates a system service (runs as root for USB access)"
 echo " 3. Starts at boot in Desktop Mode AND Game Mode"
 echo " 4. Creates a restore script for SteamOS update recovery"
 echo " 5. Creates a desktop shortcut"
 echo " 6. Shows your Steam Deck IP for the PC installer"
 echo ""
 echo "After this script, run install-phantomsense-pc.ps1 on your Windows PC."
 echo ""
 echo "Full guide: https://github.com/AarveeGill/Phantom-Sense"
 echo ""
}

# ── Get IP addresses ───────────────────────────────────────────────────────

get_deck_ip() {
 ip -4 addr show scope global 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "unknown"
}

# ── Request sudo upfront ──────────────────────────────────────────────────

request_sudo() {
 info "VirtualHere needs root access to control USB devices."
 info "You will be asked for your password once."
 echo ""
 if sudo -v 2>/dev/null; then
 ok "Sudo access granted"
 # Keep sudo alive in background
 ( while true; do sudo -v; sleep 50; done ) &
 SUDO_KEEPALIVE_PID=$!
 trap "kill $SUDO_KEEPALIVE_PID 2>/dev/null" EXIT
 else
 error "Failed to get sudo access. Please set a password first:"
 error " passwd"
 exit 1
 fi
}

# ── Clean up old v1.1.0 user service ──────────────────────────────────────

cleanup_old_user_service() {
 if [ -f "$USER_SERVICE_FILE" ]; then
 info "Found old user service from v1.1.0. Cleaning up..."
 systemctl --user stop "$SERVICE_NAME" 2>/dev/null || true
 systemctl --user disable "$SERVICE_NAME" 2>/dev/null || true
 rm -f "$USER_SERVICE_FILE"
 systemctl --user daemon-reload 2>/dev/null || true
 ok "Old user service removed"
 fi
}

# ── Create restore script ─────────────────────────────────────────────────

create_restore_script() {
 cat > "$RESTORE_SCRIPT" << 'RESTORE_EOF'
#!/bin/bash
# ============================================================================
# PhantomSense — Restore Service After SteamOS Update
# https://github.com/AarveeGill/Phantom-Sense
#
# SteamOS updates wipe /etc/systemd/system/. Run this to restore:
# sudo ~/phantomsense/restore-service.sh
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
 echo -e "${RED}[ERROR]${NC} Run with sudo: sudo ~/phantomsense/restore-service.sh"
 exit 1
fi

INSTALL_DIR="/home/deck/phantomsense"
BINARY="$INSTALL_DIR/vhusbdx86_64"

if [ ! -f "$BINARY" ]; then
 echo -e "${RED}[ERROR]${NC} VirtualHere binary not found at $BINARY"
 echo -e "${CYAN}[INFO]${NC} Re-run the full installer:"
 echo " curl -sL https://raw.githubusercontent.com/AarveeGill/Phantom-Sense/main/install-phantomsense-deck.sh | bash"
 exit 1
fi

cat > /etc/systemd/system/phantomsense.service << EOF
# PhantomSense — VirtualHere USB Server
# System service — runs as root for USB access
# https://github.com/AarveeGill/Phantom-Sense

[Unit]
Description=PhantomSense - VirtualHere USB Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=$BINARY
Restart=always
RestartSec=3
User=root
WorkingDirectory=$INSTALL_DIR

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable phantomsense.service
systemctl start phantomsense.service

echo ""
echo -e "${GREEN}[OK]${NC} PhantomSense service restored and running."
systemctl status phantomsense.service --no-pager
echo ""
RESTORE_EOF

 chmod +x "$RESTORE_SCRIPT"
}

# ── Create desktop shortcut ───────────────────────────────────────────────

create_desktop_shortcut() {
 mkdir -p "$HOME/Desktop"
 cat > "$DESKTOP_SHORTCUT" << 'DESKTOP_EOF'
[Desktop Entry]
Name=PhantomSense
Comment=PhantomSense - VirtualHere USB Server Status
Exec=konsole -e bash -c "echo '' && echo ' PhantomSense - VirtualHere USB Server' && echo ' =====================================' && echo '' && sudo systemctl status phantomsense.service --no-pager && echo '' && echo ' IP Address(es):' && ip -4 addr show scope global 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | while read ip; do echo \" $ip:7575\"; done && echo '' && echo ' Commands:' && echo ' Restart: sudo systemctl restart phantomsense' && echo ' Stop: sudo systemctl stop phantomsense' && echo ' Logs: journalctl -u phantomsense -f' && echo '' && read -p ' Press Enter to close...'"
Icon=utilities-terminal
Type=Application
Terminal=false
Categories=Utility;
DESKTOP_EOF

 chmod +x "$DESKTOP_SHORTCUT"
}

# ── Status ─────────────────────────────────────────────────────────────────

show_status() {
 banner
 step "Installation Status"

 # Binary
 if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
 ok "VirtualHere binary: $INSTALL_DIR/$BINARY_NAME"
 else
 error "VirtualHere binary: not found"
 fi

 # System service file
 if [ -f "$SYSTEM_SERVICE_FILE" ]; then
 ok "Service file: $SYSTEM_SERVICE_FILE"
 else
 error "Service file: not found"
 warn "If SteamOS was updated, restore with: sudo ~/phantomsense/restore-service.sh"
 fi

 # Restore script
 if [ -f "$RESTORE_SCRIPT" ]; then
 ok "Restore script: $RESTORE_SCRIPT"
 else
 warn "Restore script: not found"
 fi

 # Desktop shortcut
 if [ -f "$DESKTOP_SHORTCUT" ]; then
 ok "Desktop shortcut: $DESKTOP_SHORTCUT"
 else
 warn "Desktop shortcut: not found"
 fi

 # Service status
 echo ""
 if sudo systemctl is-active "$SERVICE_NAME" &>/dev/null; then
 ok "Service: running"
 echo ""
 sudo systemctl status "$SERVICE_NAME" --no-pager 2>/dev/null || true
 else
 if [ -f "$SYSTEM_SERVICE_FILE" ]; then
 warn "Service: installed but not running"
 warn "Try: sudo systemctl start phantomsense"
 else
 error "Service: not installed"
 fi
 fi

 # IP addresses
 echo ""
 step "Network"
 local ips
 ips=$(get_deck_ip)
 if [ "$ips" != "unknown" ] && [ -n "$ips" ]; then
 info "Steam Deck IP address(es):"
 echo "$ips" | while read -r ip; do
 echo -e " ${BOLD}$ip${NC} (VirtualHere Client on PC: ${ip}:7575)"
 done
 else
 warn "Could not detect IP address. Check with: ip addr"
 fi

 echo ""
}

# ── Uninstall ──────────────────────────────────────────────────────────────

uninstall() {
 banner
 step "Uninstalling PhantomSense"

 # Request sudo
 request_sudo

 # Stop and disable system service
 if sudo systemctl is-active "$SERVICE_NAME" &>/dev/null; then
 info "Stopping service..."
 sudo systemctl stop "$SERVICE_NAME"
 ok "Service stopped"
 fi

 if sudo systemctl is-enabled "$SERVICE_NAME" &>/dev/null; then
 info "Disabling service..."
 sudo systemctl disable "$SERVICE_NAME"
 ok "Service disabled"
 fi

 if [ -f "$SYSTEM_SERVICE_FILE" ]; then
 info "Removing service file..."
 sudo rm -f "$SYSTEM_SERVICE_FILE"
 sudo systemctl daemon-reload
 ok "Service file removed"
 fi

 # Clean up old user service too
 cleanup_old_user_service

 # Remove desktop shortcut
 if [ -f "$DESKTOP_SHORTCUT" ]; then
 rm -f "$DESKTOP_SHORTCUT"
 ok "Desktop shortcut removed"
 fi

 # Remove binary and install dir
 if [ -d "$INSTALL_DIR" ]; then
 if [ -t 0 ]; then
 read -rp "Remove VirtualHere binary and all files from $INSTALL_DIR? [y/N] " response
 if [[ "$response" =~ ^[Yy]$ ]]; then
 rm -rf "$INSTALL_DIR"
 ok "Installation directory removed"
 else
 info "Binary kept at $INSTALL_DIR/$BINARY_NAME"
 fi
 else
 info "Binary kept at $INSTALL_DIR/$BINARY_NAME (run interactively to remove)"
 fi
 fi

 echo ""
 ok "PhantomSense has been uninstalled from this Steam Deck."
 echo ""
}

# ── Pre-flight ─────────────────────────────────────────────────────────────

preflight() {
 step "Step 1: Pre-flight Checks"

 # Running as root check (don't run AS root, but we need sudo)
 if [ "$(id -u)" -eq 0 ]; then
 error "Do not run this script as root."
 error "Run as your normal user: ./install-phantomsense-deck.sh"
 error "The script will ask for sudo when needed."
 exit 1
 fi
 ok "Running as user: $(whoami)"

 # SteamOS check
 if [ -d "/home/deck" ] || grep -qi "steamos" /etc/os-release 2>/dev/null; then
 ok "SteamOS / Steam Deck detected"
 else
 warn "This does not appear to be a Steam Deck."
 if [ -t 0 ]; then
 read -rp "Continue anyway? [y/N] " response
 [[ ! "$response" =~ ^[Yy]$ ]] && exit 0
 fi
 fi

 # Internet
 info "Checking internet connectivity..."
 if wget -q --spider "https://www.virtualhere.com" --timeout=10 2>/dev/null; then
 ok "Internet connection: working"
 else
 error "Cannot reach virtualhere.com. Check your internet connection."
 exit 1
 fi

 # wget
 if command -v wget &>/dev/null; then
 ok "wget: available"
 else
 error "wget is required but not found."
 exit 1
 fi
}

# ── Install ────────────────────────────────────────────────────────────────

install() {
 local force=false
 [[ "${1:-}" == "--force" ]] && force=true

 banner
 preflight

 # Step 2: Sudo
 step "Step 2: Requesting sudo access"
 request_sudo

 # Step 3: Clean up old user service
 step "Step 3: Checking for previous installation"
 cleanup_old_user_service

 # Check if system service already running
 if sudo systemctl is-active "$SERVICE_NAME" &>/dev/null && [ "$force" = false ]; then
 ok "PhantomSense is already running as a system service"
 info "Use --force to reinstall, or --status to check details"
 fi

 # Step 4: Directory
 step "Step 4: Creating installation directory"
 mkdir -p "$INSTALL_DIR"
 ok "Directory: $INSTALL_DIR"

 # Step 5: Download
 step "Step 5: Downloading VirtualHere USB Server"
 if [ -f "$INSTALL_DIR/$BINARY_NAME" ] && [ "$force" = false ]; then
 ok "VirtualHere binary already exists (use --force to re-download)"
 else
 info "Downloading from virtualhere.com..."
 if wget -q --show-progress -O "$INSTALL_DIR/$BINARY_NAME" "$BINARY_URL"; then
 ok "Download complete"
 else
 error "Download failed. Check your internet connection."
 rm -f "$INSTALL_DIR/$BINARY_NAME"
 exit 1
 fi
 fi
 chmod +x "$INSTALL_DIR/$BINARY_NAME"
 ok "Binary is executable"

 # Step 6: System service
 step "Step 6: Creating system service (runs as root for USB access)"
 info "System services start at boot in Desktop Mode AND Game Mode"

 sudo tee "$SYSTEM_SERVICE_FILE" > /dev/null << EOF
# PhantomSense — VirtualHere USB Server
# System service — runs as root for USB access
# Starts at boot in both Desktop Mode and Game Mode
# https://github.com/AarveeGill/Phantom-Sense

[Unit]
Description=PhantomSense - VirtualHere USB Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/$BINARY_NAME
Restart=always
RestartSec=3
User=root
WorkingDirectory=$INSTALL_DIR

[Install]
WantedBy=multi-user.target
EOF

 ok "Service file created: $SYSTEM_SERVICE_FILE"

 sudo systemctl daemon-reload
 ok "Systemd reloaded"

 sudo systemctl enable "$SERVICE_NAME"
 ok "Service enabled (starts at boot)"

 sudo systemctl start "$SERVICE_NAME"
 sleep 2

 # Step 7: Restore script
 step "Step 7: Creating SteamOS update recovery script"
 info "SteamOS updates can wipe /etc/systemd/system/"
 info "The restore script recreates the service automatically"
 create_restore_script
 ok "Restore script saved: $RESTORE_SCRIPT"
 info "After a SteamOS update, run: sudo ~/phantomsense/restore-service.sh"

 # Step 8: Desktop shortcut
 step "Step 8: Creating desktop shortcut"
 create_desktop_shortcut
 ok "Desktop shortcut created: $DESKTOP_SHORTCUT"

 # Step 9: Verify
 step "Step 9: Verifying installation"
 if sudo systemctl is-active "$SERVICE_NAME" &>/dev/null; then
 ok "PhantomSense is running"
 echo ""
 sudo systemctl status "$SERVICE_NAME" --no-pager 2>/dev/null || true
 else
 error "Service failed to start. Checking logs..."
 echo ""
 sudo journalctl -u "$SERVICE_NAME" --no-pager -n 10 2>/dev/null || true
 echo ""
 error "Try running manually to see the error:"
 error " sudo $INSTALL_DIR/$BINARY_NAME"
 fi

 # Step 10: Network
 step "Step 10: Your Steam Deck's Network Info"
 local ips
 ips=$(get_deck_ip)
 if [ "$ips" != "unknown" ] && [ -n "$ips" ]; then
 info "Your Steam Deck IP address(es):"
 echo ""
 echo "$ips" | while read -r ip; do
 echo -e " ${BOLD}${GREEN}$ip${NC}"
 done
 echo ""
 info "Use this IP when running the PC installer."
 info "Or in VirtualHere Client: Specify Hubs > Add > <IP>:7575"
 else
 warn "Could not detect IP. Run: ip addr | grep inet"
 fi

 # Summary
 echo ""
 echo "============================================================================"
 echo ""
 echo -e " ${GREEN}${BOLD}PhantomSense Deck setup complete${NC}"
 echo ""
 echo " Installation path: $INSTALL_DIR"
 echo " Service file: $SYSTEM_SERVICE_FILE"
 echo " Restore script: $RESTORE_SCRIPT"
 echo " Desktop shortcut: $DESKTOP_SHORTCUT"
 echo " VirtualHere port: 7575 (TCP)"
 echo " Auto-start: Yes (Desktop Mode + Game Mode)"
 echo ""
 echo " Useful commands:"
 echo " Check status: sudo systemctl status phantomsense"
 echo " View logs: sudo journalctl -u phantomsense -f"
 echo " Restart: sudo systemctl restart phantomsense"
 echo " Stop: sudo systemctl stop phantomsense"
 echo " Uninstall: ./install-phantomsense-deck.sh --uninstall"
 echo ""
 echo " After SteamOS update:"
 echo " sudo ~/phantomsense/restore-service.sh"
 echo ""
 echo "============================================================================"
 echo ""
 echo -e " ${BOLD}Now set up your Windows PC:${NC}"
 echo ""
 echo " 1. Download install-phantomsense-pc.ps1 from:"
 echo " https://github.com/AarveeGill/Phantom-Sense"
 echo ""
 echo " 2. Open PowerShell as Administrator on your PC and run:"
 echo " .\\install-phantomsense-pc.ps1"
 echo ""
 echo " 3. When prompted for the Steam Deck IP, enter the address shown above."
 echo ""
 echo " 4. Plug your DualSense into the Steam Deck via USB-C."
 echo ""
 echo " 5. In VirtualHere Client on PC, attach the DualSense."
 echo ""
 echo " 6. Launch DSX on PC, configure your profiles, and start gaming."
 echo ""
 echo " Full guide: https://github.com/AarveeGill/Phantom-Sense"
 echo ""
}

# ── Main ───────────────────────────────────────────────────────────────────

main() {
 case "${1:-}" in
 --help|-h) show_help ;;
 --status|-s) show_status ;;
 --uninstall|--remove|-u) uninstall ;;
 --force|-f) install "--force" ;;
 "") install ;;
 *) error "Unknown option: $1"; echo "Run --help for usage."; exit 1 ;;
 esac
}

main "$@"
