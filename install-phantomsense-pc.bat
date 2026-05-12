@echo off
:: ============================================================================
:: PhantomSense PC Installer — Launcher
:: https://github.com/AarveeGill/Phantom-Sense
::
:: Double-click this file. It handles everything:
:: 1. Requests Administrator access (one UAC popup)
:: 2. Downloads the installer script from GitHub
:: 3. Runs it with execution policy bypass
:: 4. Keeps the window open when done
:: ============================================================================

title PhantomSense PC Installer

:: ── Check for Administrator ──────────────────────────────────────────────
net session >nul 2>&1
if %errorlevel% neq 0 (
 echo.
 echo PhantomSense PC Installer
 echo ========================
 echo.
 echo Requesting Administrator access...
 echo Click "Yes" on the popup to continue.
 echo.
 powershell -Command "Start-Process '%~f0' -Verb RunAs"
 exit /b
)

:: ── We are Admin — proceed ───────────────────────────────────────────────
cls
echo.
echo ============================================================
echo.
echo PhantomSense PC Installer
echo Your PC sees a DualSense that isn't there.
echo https://github.com/AarveeGill/Phantom-Sense
echo.
echo ============================================================
echo.

:: ── Download the installer script ────────────────────────────────────────
set "PS1_URL=https://raw.githubusercontent.com/AarveeGill/Phantom-Sense/main/install-phantomsense-pc.ps1"
set "PS1_PATH=%TEMP%\install-phantomsense-pc.ps1"

echo [1/3] Downloading installer from GitHub...
echo.
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%PS1_URL%' -OutFile '%PS1_PATH%' -UseBasicParsing"

if not exist "%PS1_PATH%" (
 echo.
 echo [ERROR] Download failed. Check your internet connection.
 echo [ERROR] You can download manually from:
 echo %PS1_URL%
 echo.
 pause
 exit /b 1
)

echo [OK] Downloaded successfully.
echo.

:: ── Run the installer ────────────────────────────────────────────────────
echo [2/3] Starting PhantomSense installer...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1_PATH%"

:: ── Done ─────────────────────────────────────────────────────────────────
echo.
echo [3/3] Installer complete.
echo.
echo ============================================================
echo You can close this window now.
echo ============================================================
echo.
pause
