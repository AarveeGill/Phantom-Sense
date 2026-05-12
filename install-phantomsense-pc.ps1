# ============================================================================
# PhantomSense PC Installer v1.1.0
# https://github.com/AarveeGill/Phantom-Sense
#
# Automated setup for the Windows PC side of PhantomSense
# Installs VirtualHere Client, ViGEmBus, HidHide, DSX, and configures Sunshine
#
# EASY INSTALL: Double-click install-phantomsense-pc.bat
# It handles admin elevation and execution policy automatically.
#
# MANUAL: Run PowerShell as Administrator:
#   Set-ExecutionPolicy Bypass -Scope Process -Force
#   .\install-phantomsense-pc.ps1
# ============================================================================

param(
    [switch]$Status,
    [switch]$Uninstall,
    [switch]$Help,
    [switch]$SkipHidHide,
    [switch]$Force
)

# ── Configuration ──────────────────────────────────────────────────────────

$PhantomSenseVersion = "1.1.0"
$InstallDir = "C:\PhantomSense"
$TempDir = "$InstallDir\installers"

$VHClientURL = "https://www.virtualhere.com/sites/default/files/usbclient/vhui64.exe"
$VHClientPath = "$InstallDir\vhui64.exe"

$ViGEmBusURL = "https://github.com/nefarius/ViGEmBus/releases/download/v1.22.0/ViGEmBus_1.22.0_x64_x86_arm64.exe"
$ViGEmBusInstaller = "$TempDir\ViGEmBus_Setup.exe"

$HidHideURL = "https://github.com/nefarius/HidHide/releases/download/v1.5.230.0/HidHide_1.5.230_x64.exe"
$HidHideInstaller = "$TempDir\HidHide_Setup.exe"

$DSXFreeURL = "https://github.com/Paliverse/DualSenseX/releases/download/1.4.9/DualSenseX-Setup.zip"
$DSXFreeZip = "$TempDir\DualSenseX-Setup.zip"
$DSXSteamURL = "https://store.steampowered.com/app/1812620/DSX/"

$SunshineConfigPaths = @(
    "$env:ProgramFiles\Sunshine\config\sunshine.conf",
    "$env:APPDATA\Sunshine\config\sunshine.conf",
    "${env:ProgramFiles(x86)}\Sunshine\config\sunshine.conf"
)

# ── Logging ────────────────────────────────────────────────────────────────

function Write-OK    { param($msg) Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-Info  { param($msg) Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Warn  { param($msg) Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err   { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Step  { param($msg) Write-Host "`n--- $msg ---" -ForegroundColor White -BackgroundColor DarkGray }

# ── Banner ─────────────────────────────────────────────────────────────────

function Show-Banner {
    Write-Host ""
    Write-Host "  PhantomSense PC Installer v$PhantomSenseVersion" -ForegroundColor White
    Write-Host "  Your PC sees a DualSense that isn't there." -ForegroundColor Gray
    Write-Host "  https://github.com/AarveeGill/Phantom-Sense" -ForegroundColor DarkCyan
    Write-Host ""
}

# ── Help ───────────────────────────────────────────────────────────────────

function Show-Help {
    Show-Banner
    Write-Host "Usage (Run PowerShell as Administrator):"
    Write-Host "  .\install-phantomsense-pc.ps1             Install everything"
    Write-Host "  .\install-phantomsense-pc.ps1 -Status     Check installation status"
    Write-Host "  .\install-phantomsense-pc.ps1 -Uninstall  Remove PhantomSense"
    Write-Host "  .\install-phantomsense-pc.ps1 -SkipHidHide  Skip HidHide installation"
    Write-Host "  .\install-phantomsense-pc.ps1 -Force      Force reinstall"
    Write-Host "  .\install-phantomsense-pc.ps1 -Help       Show this help"
    Write-Host ""
    Write-Host "What this script installs:"
    Write-Host "  1. VirtualHere Client    - Receives the DualSense over the network"
    Write-Host "  2. ViGEmBus Driver       - Virtual gamepad bus required by DSX"
    Write-Host "  3. HidHide (optional)    - Prevents double-input from raw HID"
    Write-Host "  4. Sunshine config       - Disables controller (video/audio only)"
    Write-Host "  5. DSX (free or paid)    - Enables Adaptive Triggers and Haptics"
    Write-Host ""
    Write-Host "After running this script, run install-phantomsense-deck.sh on your Steam Deck."
    Write-Host ""
    Write-Host "Full guide: https://github.com/AarveeGill/Phantom-Sense"
    Write-Host ""
}

# ── Admin Check ────────────────────────────────────────────────────────────

function Assert-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
    if (-not $isAdmin) {
        Write-Err "This script must be run as Administrator."
        Write-Err "Right-click PowerShell > 'Run as Administrator' and try again."
        exit 1
    }
}

# ── Download Helper ────────────────────────────────────────────────────────

function Get-File {
    param(
        [string]$Url,
        [string]$Destination,
        [string]$Description
    )
    Write-Info "Downloading $Description..."
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -TimeoutSec 120
        $ProgressPreference = 'Continue'
        if (Test-Path $Destination) {
            $size = [math]::Round((Get-Item $Destination).Length / 1MB, 1)
            Write-OK "Downloaded $Description (${size} MB)"
        } else {
            Write-Err "Download failed: file not found after download"
            return $false
        }
    } catch {
        Write-Err "Download failed for ${Description}: $_"
        return $false
    }
    return $true
}

# ── Status ─────────────────────────────────────────────────────────────────

function Show-Status {
    Show-Banner
    Write-Step "Installation Status"

    # VirtualHere Client
    if (Test-Path $VHClientPath) {
        Write-OK "VirtualHere Client: $VHClientPath"
    } else {
        Write-Err "VirtualHere Client: not found"
    }

    # ViGEmBus
    $vigemReg = Get-ItemProperty "HKLM:\SOFTWARE\Nefarius Software Solutions e.U.\ViGEm Bus Driver" -ErrorAction SilentlyContinue
    if ($vigemReg) {
        Write-OK "ViGEmBus Driver: installed"
    } else {
        Write-Err "ViGEmBus Driver: not found"
    }

    # HidHide
    $hidHideService = Get-Service "HidHide" -ErrorAction SilentlyContinue
    if ($hidHideService) {
        Write-OK "HidHide: installed (service: $($hidHideService.Status))"
    } else {
        Write-Warn "HidHide: not installed (optional)"
    }

    # Sunshine config
    $sunshineFound = $false
    foreach ($path in $SunshineConfigPaths) {
        if (Test-Path $path) {
            $content = Get-Content $path -Raw -ErrorAction SilentlyContinue
            if ($content -match "controller\s*=\s*disabled") {
                Write-OK "Sunshine config: controller disabled ($path)"
            } else {
                Write-Warn "Sunshine config: found but controller not disabled ($path)"
            }
            $sunshineFound = $true
            break
        }
    }
    if (-not $sunshineFound) {
        Write-Warn "Sunshine config: not found"
    }

    # DSX
    $dsxFree = Test-Path "$InstallDir\DualSenseX"
    $dsxProc = Get-Process -Name "DualSenseX","DSX" -ErrorAction SilentlyContinue
    if ($dsxProc) {
        Write-OK "DSX: running"
    } elseif ($dsxFree) {
        Write-OK "DSX Free: installed at $InstallDir\DualSenseX"
    } else {
        Write-Info "DSX: not detected (may be installed via Steam)"
    }

    Write-Host ""
}

# ── Uninstall ──────────────────────────────────────────────────────────────

function Start-Uninstall {
    Show-Banner
    Assert-Admin
    Write-Step "Uninstalling PhantomSense PC Components"

    if (Test-Path $InstallDir) {
        Write-Info "Removing PhantomSense directory..."
        Remove-Item $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-OK "Directory removed: $InstallDir"
    }

    # Remove desktop shortcut
    $shortcutPath = "$env:PUBLIC\Desktop\VirtualHere Client.lnk"
    if (Test-Path $shortcutPath) {
        Remove-Item $shortcutPath -Force -ErrorAction SilentlyContinue
        Write-OK "Desktop shortcut removed"
    }

    Write-Host ""
    Write-Info "ViGEmBus and HidHide must be removed manually:"
    Write-Info "  Settings > Apps > search 'ViGEm' or 'HidHide' > Uninstall"
    Write-Host ""
    Write-Info "To restore Sunshine controller passthrough:"
    Write-Info "  Edit sunshine.conf and remove: controller = disabled"
    Write-Host ""
    Write-OK "PhantomSense PC components have been removed."
    Write-Host ""
}

# ── Install ────────────────────────────────────────────────────────────────

function Start-Install {
    Show-Banner
    Assert-Admin

    $needsReboot = $false

    # ── Step 1: Pre-flight ──

    Write-Step "Step 1: Pre-flight Checks"
    Write-OK "Running as Administrator"

    $os = [System.Environment]::OSVersion
    if ($os.Version.Major -ge 10) {
        Write-OK "Windows version: $($os.VersionString)"
    } else {
        Write-Err "Windows 10 or 11 is required."
        exit 1
    }

    Write-Info "Checking internet connectivity..."
    try {
        $null = Invoke-WebRequest -Uri "https://www.virtualhere.com" -UseBasicParsing -TimeoutSec 10 -Method Head
        Write-OK "Internet connection: working"
    } catch {
        Write-Err "Cannot reach virtualhere.com. Check your internet connection."
        exit 1
    }

    # ── Step 2: Create directories ──

    Write-Step "Step 2: Creating directories"
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    Write-OK "Directory: $InstallDir"

    # ── Step 3: VirtualHere Client ──

    Write-Step "Step 3: Installing VirtualHere Client"
    if ((Test-Path $VHClientPath) -and (-not $Force)) {
        Write-OK "VirtualHere Client already exists (use -Force to re-download)"
    } else {
        $result = Get-File -Url $VHClientURL -Destination $VHClientPath -Description "VirtualHere Client"
        if (-not $result) {
            Write-Err "Failed to download VirtualHere Client."
        }
    }

    # Desktop shortcut
    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $shortcut = $WshShell.CreateShortcut("$env:PUBLIC\Desktop\VirtualHere Client.lnk")
        $shortcut.TargetPath = $VHClientPath
        $shortcut.WorkingDirectory = $InstallDir
        $shortcut.Description = "PhantomSense - VirtualHere USB Client"
        $shortcut.Save()
        Write-OK "Desktop shortcut created"
    } catch {
        Write-Warn "Could not create desktop shortcut: $_"
    }

    # ── Step 4: ViGEmBus ──

    Write-Step "Step 4: Installing ViGEmBus Driver"
    $vigemReg = Get-ItemProperty "HKLM:\SOFTWARE\Nefarius Software Solutions e.U.\ViGEm Bus Driver" -ErrorAction SilentlyContinue
    if ($vigemReg -and (-not $Force)) {
        Write-OK "ViGEmBus is already installed"
    } else {
        $result = Get-File -Url $ViGEmBusURL -Destination $ViGEmBusInstaller -Description "ViGEmBus Driver"
        if ($result) {
            Write-Info "Installing ViGEmBus (this may take a moment)..."
            try {
                $proc = Start-Process -FilePath $ViGEmBusInstaller -ArgumentList "/quiet","/norestart" -Wait -PassThru
                if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                    Write-OK "ViGEmBus installed successfully"
                    if ($proc.ExitCode -eq 3010) { $needsReboot = $true }
                } else {
                    Write-Warn "ViGEmBus installer returned code: $($proc.ExitCode)"
                    Write-Info "Install manually: https://github.com/nefarius/ViGEmBus/releases"
                }
            } catch {
                Write-Err "ViGEmBus installation failed: $_"
            }
        }
    }

    # ── Step 5: HidHide ──

    Write-Step "Step 5: Installing HidHide"
    if ($SkipHidHide) {
        Write-Info "HidHide installation skipped (-SkipHidHide flag)"
    } else {
        $hidHideService = Get-Service "HidHide" -ErrorAction SilentlyContinue
        if ($hidHideService -and (-not $Force)) {
            Write-OK "HidHide is already installed"
        } else {
            Write-Info "HidHide prevents double-input by hiding the raw controller from games."
            $result = Get-File -Url $HidHideURL -Destination $HidHideInstaller -Description "HidHide"
            if ($result) {
                Write-Info "Installing HidHide (this may take a moment)..."
                try {
                    $proc = Start-Process -FilePath $HidHideInstaller -ArgumentList "/quiet","/norestart" -Wait -PassThru
                    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                        Write-OK "HidHide installed successfully"
                        $needsReboot = $true
                        Write-Warn "A reboot is required to activate HidHide"
                    } else {
                        Write-Warn "HidHide installer returned code: $($proc.ExitCode)"
                    }
                } catch {
                    Write-Warn "HidHide installation failed: $_"
                }
            }
        }
    }

    # ── Step 6: Sunshine Config ──

    Write-Step "Step 6: Configuring Sunshine"
    $sunshineConfigured = $false
    foreach ($confPath in $SunshineConfigPaths) {
        if (Test-Path $confPath) {
            Write-Info "Found Sunshine config: $confPath"
            $content = Get-Content $confPath -Raw
            if ($content -match "controller\s*=\s*disabled") {
                Write-OK "Sunshine controller already set to disabled"
            } else {
                Copy-Item $confPath "$confPath.phantomsense.backup" -Force
                Write-Info "Backup saved: $confPath.phantomsense.backup"
                if ($content -match "controller\s*=") {
                    $content = $content -replace "controller\s*=\s*\w+", "controller = disabled"
                } else {
                    $content += "`ncontroller = disabled`n"
                }
                Set-Content -Path $confPath -Value $content
                Write-OK "Sunshine controller set to disabled (video/audio only)"
                Write-Info "Restart Sunshine for changes to take effect"
            }
            $sunshineConfigured = $true
            break
        }
    }
    if (-not $sunshineConfigured) {
        Write-Warn "Sunshine config not found. Manually add to sunshine.conf:"
        Write-Info "  controller = disabled"
    }

    # ── Step 7: DSX (DualSenseX) ──

    Write-Step "Step 7: DSX (DualSenseX)"
    Write-Host ""
    Write-Info "DSX enables Adaptive Triggers and HD Haptics for the DualSense on PC."
    Write-Info "Two versions are available:"
    Write-Host ""

    # Comparison table
    Write-Host "  +-----------------------------+------------------+----------------------+" -ForegroundColor DarkGray
    Write-Host "  | Feature                     | Free (v1.4.9)    | Paid (Steam v3.x)    |" -ForegroundColor DarkGray
    Write-Host "  +-----------------------------+------------------+----------------------+" -ForegroundColor DarkGray
    Write-Host "  | Adaptive Triggers           | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "              | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "                  |" -ForegroundColor DarkGray

    Write-Host "  | HD Haptics (USB)            | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "              | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "                  |" -ForegroundColor DarkGray

    Write-Host "  | Bluetooth Audio/Haptics     | " -NoNewline -ForegroundColor DarkGray
    Write-Host "No" -NoNewline -ForegroundColor Red
    Write-Host "               | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes (with DLC)" -NoNewline -ForegroundColor Green
    Write-Host "        |" -ForegroundColor DarkGray

    Write-Host "  | Xbox 360 Emulation          | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "              | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "                  |" -ForegroundColor DarkGray

    Write-Host "  | DS4 Emulation               | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "              | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "                  |" -ForegroundColor DarkGray

    Write-Host "  | Multi-Controller Support    | " -NoNewline -ForegroundColor DarkGray
    Write-Host "No" -NoNewline -ForegroundColor Red
    Write-Host "               | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "                  |" -ForegroundColor DarkGray

    Write-Host "  | Custom Profiles             | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Basic" -NoNewline -ForegroundColor Yellow
    Write-Host "            | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Advanced" -NoNewline -ForegroundColor Green
    Write-Host "              |" -ForegroundColor DarkGray

    Write-Host "  | Touchpad to Mouse           | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "              | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Yes" -NoNewline -ForegroundColor Green
    Write-Host "                  |" -ForegroundColor DarkGray

    Write-Host "  | Updates                     | " -NoNewline -ForegroundColor DarkGray
    Write-Host "No (Dec 2021)" -NoNewline -ForegroundColor Red
    Write-Host "    | " -NoNewline -ForegroundColor DarkGray
    Write-Host "Active (2026)" -NoNewline -ForegroundColor Green
    Write-Host "         |" -ForegroundColor DarkGray

    Write-Host "  | Cost                        | " -NoNewline -ForegroundColor DarkGray
    Write-Host "FREE" -NoNewline -ForegroundColor Green
    Write-Host "             | " -NoNewline -ForegroundColor DarkGray
    Write-Host "`$7.99 (+`$3.99 DLC)" -NoNewline -ForegroundColor Yellow
    Write-Host "   |" -ForegroundColor DarkGray

    Write-Host "  +-----------------------------+------------------+----------------------+" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "  Which version would you like to install?" -ForegroundColor White
    Write-Host ""
    Write-Host "    [1] Free (v1.4.9)  - Download and install now (works for PhantomSense)" -ForegroundColor Green
    Write-Host "    [2] Paid (Steam)   - Opens Steam store page (`$7.99, actively updated)" -ForegroundColor Cyan
    Write-Host "    [3] Skip           - Already have DSX or will install later" -ForegroundColor Gray
    Write-Host ""

    $dsxChoice = Read-Host "Enter your choice [1/2/3]"

    switch ($dsxChoice) {
        "1" {
            Write-Host ""
            Write-Info "Installing DSX Free (v1.4.9) from GitHub..."
            Write-Info "This version is no longer updated but works perfectly for PhantomSense."
            Write-Info "Requires ViGEmBus (already installed in Step 4)."
            Write-Host ""

            $result = Get-File -Url $DSXFreeURL -Destination $DSXFreeZip -Description "DualSenseX v1.4.9"
            if ($result) {
                Write-Info "Extracting DualSenseX..."
                $dsxInstallDir = "$InstallDir\DualSenseX"
                New-Item -ItemType Directory -Path $dsxInstallDir -Force | Out-Null
                Expand-Archive -Path $DSXFreeZip -DestinationPath $dsxInstallDir -Force
                Write-OK "DualSenseX extracted to: $dsxInstallDir"

                $setupExe = Get-ChildItem -Path $dsxInstallDir -Filter "DualSenseX-Setup.exe" -Recurse | Select-Object -First 1
                if ($setupExe) {
                    Write-Info "Running DualSenseX installer..."
                    try {
                        $proc = Start-Process -FilePath $setupExe.FullName -Wait -PassThru
                        if ($proc.ExitCode -eq 0) {
                            Write-OK "DualSenseX installed successfully"
                        } else {
                            Write-Warn "Installer exited with code: $($proc.ExitCode)"
                            Write-Info "You can run the installer manually: $($setupExe.FullName)"
                        }
                    } catch {
                        Write-Warn "Could not run installer automatically: $_"
                        Write-Info "Run manually: $($setupExe.FullName)"
                    }
                } else {
                    Write-OK "DualSenseX files extracted to: $dsxInstallDir"
                    Write-Info "Look for DualSenseX-Setup.exe inside and run it manually."
                }
            }
        }
        "2" {
            Write-Host ""
            Write-Info "DSX on Steam:"
            Write-Host ""
            Write-Host "    DSX Base App:             `$7.99" -ForegroundColor White
            Write-Host "    DSX + Haptics DLC Bundle:  `$9.58 (save 20%)" -ForegroundColor White
            Write-Host ""
            Write-Info "Steam page: $DSXSteamURL"
            Write-Host ""
            Start-Process $DSXSteamURL
            Write-OK "Opened DSX Steam page in browser"
            Write-Info "Install DSX from Steam, then launch it after setup is complete."
        }
        "3" {
            Write-Info "DSX installation skipped."
            Write-Info "You can install DSX later from GitHub (free) or Steam (paid)."
            Write-Info "  Free:  https://github.com/Paliverse/DualSenseX/releases/tag/1.4.9"
            Write-Info "  Paid:  $DSXSteamURL"
        }
        default {
            Write-Warn "Invalid choice. Skipping DSX installation."
            Write-Info "  Free:  https://github.com/Paliverse/DualSenseX/releases/tag/1.4.9"
            Write-Info "  Paid:  $DSXSteamURL"
        }
    }

    # ── Step 8: Steam Deck IP ──

    Write-Step "Step 8: Connect to Steam Deck"
    Write-Host ""
    Write-Info "To connect VirtualHere Client to your Steam Deck, enter the Deck's IP."
    Write-Info "Run this on the Steam Deck to find it: ip addr | grep inet"
    Write-Host ""

    $deckIP = Read-Host "Enter your Steam Deck's IP address (or press Enter to skip)"

    if ($deckIP -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
        Write-OK "Steam Deck IP: $deckIP"
        Write-Info "In VirtualHere Client: Right-click > Specify Hubs > Add > ${deckIP}:7575"
    } elseif ($deckIP -eq "") {
        Write-Info "Skipped. Add the Steam Deck IP later in VirtualHere Client."
    } else {
        Write-Warn "Invalid IP format. Add the Steam Deck IP later."
    }

    # ── Cleanup ──

    Write-Info "Cleaning up installer files..."
    Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-OK "Installer temp files removed"

    # ── Summary ──

    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  PhantomSense PC setup complete" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Installed to:            $InstallDir"
    Write-Host "  VirtualHere Client:      $VHClientPath"
    Write-Host "  ViGEmBus:                Installed"
    if (-not $SkipHidHide) {
        Write-Host "  HidHide:                 Installed"
    }
    Write-Host "  Sunshine:                Controller disabled"
    switch ($dsxChoice) {
        "1" { Write-Host "  DSX:                     Free v1.4.9 installed" }
        "2" { Write-Host "  DSX:                     Install from Steam when ready" }
        default { Write-Host "  DSX:                     Skipped" }
    }
    Write-Host ""

    if ($needsReboot) {
        Write-Host "  *** REBOOT REQUIRED ***" -ForegroundColor Yellow
        Write-Host "  Some drivers need a restart to take effect." -ForegroundColor Yellow
        Write-Host ""
    }

    Write-Host "  Useful commands:" -ForegroundColor White
    Write-Host "    Check status:          .\install-phantomsense-pc.ps1 -Status"
    Write-Host "    Uninstall:             .\install-phantomsense-pc.ps1 -Uninstall"
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Next steps:" -ForegroundColor White
    Write-Host ""
    if ($needsReboot) {
        Write-Host "  1. Reboot your PC now" -ForegroundColor Yellow
        Write-Host ""
    }
    Write-Host "  2. On your Steam Deck, run:" -ForegroundColor Cyan
    Write-Host "     curl -sL https://raw.githubusercontent.com/AarveeGill/Phantom-Sense/main/install-phantomsense-deck.sh | bash"
    Write-Host ""
    Write-Host "  3. Plug your DualSense into the Steam Deck via USB-C"
    Write-Host ""
    Write-Host "  4. Launch VirtualHere Client on this PC (desktop shortcut)"
    Write-Host "     - Expand the Steam Deck node"
    Write-Host "     - Right-click the DualSense > 'Use this device'"
    Write-Host ""
    Write-Host "  5. Launch DSX (free or Steam version)"
    Write-Host "     - DualSense appears as connected controller"
    Write-Host "     - Configure Adaptive Triggers and Haptics profiles"
    Write-Host ""
    Write-Host "  6. Launch Moonlight on Steam Deck and start streaming"
    Write-Host "     - Moonlight carries video/audio only"
    Write-Host "     - DualSense runs through VirtualHere with full features"
    Write-Host ""
    Write-Host "  Full guide: https://github.com/AarveeGill/Phantom-Sense" -ForegroundColor DarkCyan
    Write-Host ""

    if ($needsReboot) {
        $rebootNow = Read-Host "Reboot now? [y/N]"
        if ($rebootNow -eq "y" -or $rebootNow -eq "Y") {
            Write-Info "Rebooting in 10 seconds... Press Ctrl+C to cancel."
            shutdown /r /t 10 /c "PhantomSense: Restarting to complete driver installation"
        }
    }
}

# ── Main ───────────────────────────────────────────────────────────────────

if ($Help) {
    Show-Help
} elseif ($Status) {
    Show-Status
} elseif ($Uninstall) {
    Start-Uninstall
} else {
    Start-Install
}
