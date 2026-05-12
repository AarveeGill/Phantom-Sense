#!/bin/bash
# ============================================================================
# PhantomSense Deck Installer v1.1.0
# https://github.com/AarveeGill/Phantom-Sense
#
# One-command installer for Steam Deck (SteamOS)
# Installs VirtualHere USB Server as a persistent user service
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/AarveeGill/Phantom-Sense/main/install-phantomsense-deck.sh | bash
#
# Or download and run:
#   ./install-phantomsense-deck.sh             Install PhantomSense
#   ./install-phantomsense-deck.sh --status    Check installation status
#   ./install-phantomsense-deck.sh --uninstall Remove PhantomSense
#   ./install-phantomsense-deck.sh --help      Show help
#
# Why user services?
#   SteamOS updates wipe /etc/systemd/system/ but NOT ~/.config/systemd/user/
#   PhantomSense survives every SteamOS update without reinstallation.
# ============================================================================

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────

PHANTOMSENSE_VERSION="1.1.0"
INSTALL_DIR="$HOME/phantomsense"
BINARY_NAME="vhusbdx86_64"
BINARY_URL="https://www.virtualhere.com/sites/default/files/usbserver/vhusbdx86_64"
SERVICE_NAME="phantomsense"
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/$SERVICE_NAME.service"

# ── Colors ─────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Logging ────────────────────────────────────────────────────────────────

info()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step()  { echo -e "\n${BOLD}--- $1 ---${NC}"; }

# ── Banner ─────────────────────────────────────────────────────────────────

banner() {
    echo ""
    echo -e "${BOLD}  PhantomSense Deck Installer v${PHANTOMSENSE_VERSION}${NC}"
    echo "  Your PC sees a DualSense that isn't there."
    echo "  https://github.com/AarveeGill/Phantom-Sense"
    echo ""
}

# ── Help ───────────────────────────────────────────────────────────────────

show_help() {
    banner
    echo "Usage:"
    echo "  ./install-phantomsense-deck.sh             Install PhantomSense"
    echo "  ./install-phantomsense-deck.sh --status    Check installation status"
    echo "  ./install-phantomsense-deck.sh --uninstall Remove PhantomSense"
    echo "  ./install-phantomsense-deck.sh --force     Reinstall (re-download binary)"
    echo "  ./install-phantomsense-deck.sh --help      Show this help"
    echo ""
    echo "Or install directly with one command:"
    echo "  curl -sL https://raw.githubusercontent.com/AarveeGill/Phantom-Sense/main/install-phantomsense-deck.sh | bash"
    echo ""
    echo "What this script does:"
    echo "  1. Downloads VirtualHere USB Server binary"
    echo "  2. Creates a systemd user service (survives SteamOS updates)"
    echo "  3. Enables auto-start at boot (via linger)"
    echo "  4. Starts the VirtualHere server"
    echo "  5. Shows your Steam Deck IP for the PC installer"
    echo ""
    echo "After this script, run install-phantomsense-pc.ps1 on your Windows PC."
    echo ""
    echo "Full guide: https://github.com/AarveeGill/Phantom-Sense"
    echo ""
}

# ── Get IP addresses ───────────────────────────────────────────────────────

get_deck_ip() {
    # Get non-loopback IPv4 addresses
    ip -4 addr show scope global 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "unknown"
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

    # Service file
    if [ -f "$SERVICE_FILE" ]; then
        ok "Service file: $SERVICE_FILE"
    else
        error "Service file: not found"
    fi

    # Linger
    if loginctl show-user "$(whoami)" 2>/dev/null | grep -q "Linger=yes"; then
        ok "Linger: enabled (service runs at boot without login)"
    else
        warn "Linger: not enabled (service starts only after login)"
    fi

    # Service status
    echo ""
    if systemctl --user is-active "$SERVICE_NAME" &>/dev/null; then
        ok "Service: running"
        echo ""
        systemctl --user status "$SERVICE_NAME" --no-pager 2>/dev/null || true
    else
        if systemctl --user is-enabled "$SERVICE_NAME" &>/dev/null; then
            warn "Service: enabled but not running"
        else
            error "Service: not installed or not enabled"
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
            echo -e "  ${BOLD}$ip${NC}  (use this in VirtualHere Client on PC as ${ip}:7575)"
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

    if systemctl --user is-active "$SERVICE_NAME" &>/dev/null; then
        info "Stopping service..."
        systemctl --user stop "$SERVICE_NAME"
        ok "Service stopped"
    fi

    if systemctl --user is-enabled "$SERVICE_NAME" &>/dev/null; then
        info "Disabling service..."
        systemctl --user disable "$SERVICE_NAME"
        ok "Service disabled"
    fi

    if [ -f "$SERVICE_FILE" ]; then
        info "Removing service file..."
        rm -f "$SERVICE_FILE"
        systemctl --user daemon-reload
        ok "Service file removed"
    fi

    if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
        if [ -t 0 ]; then
            read -rp "Remove VirtualHere binary and config from $INSTALL_DIR? [y/N] " response
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

    # Not root
    if [ "$(id -u)" -eq 0 ]; then
        error "Do not run this script as root or with sudo."
        error "PhantomSense uses systemd user services. Run as: ./install-phantomsense-deck.sh"
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

    # Step 2: Directory
    step "Step 2: Creating installation directory"
    mkdir -p "$INSTALL_DIR"
    ok "Directory: $INSTALL_DIR"

    # Step 3: Download
    step "Step 3: Downloading VirtualHere USB Server"
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

    # Step 4: User service
    step "Step 4: Creating systemd user service"
    info "User services persist across SteamOS updates"

    mkdir -p "$SERVICE_DIR"

    cat > "$SERVICE_FILE" << EOF
# PhantomSense — VirtualHere USB Server
# User service — persists across SteamOS updates
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
WorkingDirectory=$INSTALL_DIR

[Install]
WantedBy=default.target
EOF

    ok "Service file created: $SERVICE_FILE"

    # Step 5: Linger
    step "Step 5: Enabling linger for auto-start at boot"
    if loginctl enable-linger "$(whoami)" 2>/dev/null; then
        ok "Linger enabled for user: $(whoami)"
    else
        warn "Could not enable linger. Try: sudo loginctl enable-linger $(whoami)"
        warn "Without linger, service starts only after login."
    fi

    # Step 6: Start
    step "Step 6: Starting PhantomSense"

    systemctl --user is-active "$SERVICE_NAME" &>/dev/null && systemctl --user stop "$SERVICE_NAME"

    systemctl --user daemon-reload
    ok "Systemd reloaded"

    systemctl --user enable "$SERVICE_NAME"
    ok "Service enabled (starts at boot)"

    systemctl --user start "$SERVICE_NAME"
    sleep 2

    # Verify
    step "Step 7: Verifying installation"
    if systemctl --user is-active "$SERVICE_NAME" &>/dev/null; then
        ok "PhantomSense is running"
    else
        warn "Service may not have started correctly."
        warn "VirtualHere may need root access for USB. Try:"
        warn "  sudo $INSTALL_DIR/$BINARY_NAME"
        systemctl --user status "$SERVICE_NAME" --no-pager 2>/dev/null || true
    fi

    # Get IP
    step "Step 8: Your Steam Deck's Network Info"
    local ips
    ips=$(get_deck_ip)
    if [ "$ips" != "unknown" ] && [ -n "$ips" ]; then
        info "Your Steam Deck IP address(es):"
        echo ""
        echo "$ips" | while read -r ip; do
            echo -e "    ${BOLD}${GREEN}$ip${NC}"
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
    echo -e "  ${GREEN}${BOLD}PhantomSense Deck setup complete${NC}"
    echo ""
    echo "  Installation path:  $INSTALL_DIR"
    echo "  Service file:       $SERVICE_FILE"
    echo "  VirtualHere port:   7575 (TCP)"
    echo ""
    echo "  Useful commands:"
    echo "    Check status:     systemctl --user status phantomsense"
    echo "    View logs:        journalctl --user -u phantomsense -f"
    echo "    Restart:          systemctl --user restart phantomsense"
    echo "    Stop:             systemctl --user stop phantomsense"
    echo "    Uninstall:        ./install-phantomsense-deck.sh --uninstall"
    echo ""
    echo "============================================================================"
    echo ""
    echo -e "  ${BOLD}Now set up your Windows PC:${NC}"
    echo ""
    echo "  1. Download install-phantomsense-pc.ps1 from:"
    echo "     https://github.com/AarveeGill/Phantom-Sense"
    echo ""
    echo "  2. Open PowerShell as Administrator on your PC and run:"
    echo "     .\install-phantomsense-pc.ps1"
    echo ""
    echo "  3. When prompted for the Steam Deck IP, enter the address shown above."
    echo ""
    echo "  4. Plug your DualSense into the Steam Deck via USB-C."
    echo ""
    echo "  5. In VirtualHere Client on PC, attach the DualSense."
    echo ""
    echo "  6. Launch DSX on PC, configure your profiles, and start gaming."
    echo ""
    echo "  Full guide: https://github.com/AarveeGill/Phantom-Sense"
    echo ""
}

# ── Main ───────────────────────────────────────────────────────────────────

main() {
    case "${1:-}" in
        --help|-h)    show_help ;;
        --status|-s)  show_status ;;
        --uninstall|--remove|-u) uninstall ;;
        --force|-f)   install "--force" ;;
        "")           install ;;
        *)            error "Unknown option: $1"; echo "Run --help for usage."; exit 1 ;;
    esac
}

main "$@"
