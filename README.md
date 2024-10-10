# Collection of Windows scripts



## Auto Dark Mode helper script

PowerShell script that enhances AutoDarkMode Scripts, fixes Windows artifacts when switching themes with advanced functions.

### 🔥 Features

- Prevent ADM script multiple instance (lock file)  
- Restart `explorer.exe` and restore tabs  
- Launch external scripts  
- Refresh ADM theme to fix wallpaper not changing error (force theme toggle)  
- Restore last active window (ps\\foregroundWindow.ps1)

### 🔗 [More info](./Docs/ADM_Helper.md) — installation, usage, examples

<br>

## Telegram webm video sticker converter

Create Telegram video sticker files using FFmpeg.

### 🔥 Features

- Convert any video (FFmpeg)
- Resize up to `512x512px`
- Output `.webm` file is ready to share to Telegram Sticker Bot

### 🔗 [More info](./Docs/Telegram_videosticker.md) — usage, customization, example

<br>

## Theme scripts

### Usage example

```powershell
& ".\theme_yf_w11.ps1"          # Light theme
& ".\theme_yf_w11.ps1" -Dark    # Dark theme
```

### YourFlyouts2 (theme_yf2_w11.ps1)

- Check for `Rainmeter` and `YF2` installed
- Set Win11 skin to light or dark

Accent color is imported from the system.

![YF2](./Screenshots/Theme_YF2.jpg)

### qBittorrent (theme_qbittorrent.ps1)

Enable `custom UI Theme` and then restart qBittorrent.

**Pre-setup:**
1. Download any dark theme and put somewhere
2. In qBittorrent settings enable and select `custom UI Theme`
3. Uncheck:
    - `Show qBittorrent in notification area`
    - `Confirmation on exit when torrents are active`

<br>



## Useful snippets

### (PowerShell) AutoDarkMode silent uninstaller

```powershell
"";function w($x){Write-Host "> $x"-f 3};$a="AutoDarkMode";if($null=gps "${a}Svc" -ea 0){w "Shutdown <$a>...";$aw=$true;$null=& "$env:LOCALAPPDATA\Programs\$a\adm-app\${a}Shell.exe" --exit;sleep 2};w "Uninstall <$a>...";saps "$env:LOCALAPPDATA\Programs\$a\unins000.exe" "/VERYSILENT" -wait;w "Remove leftovers";ri "$env:APPDATA\$a" -r -for;""
```

### (PowerShell) Rainmeter silent uninstaller

```powershell
"";function w($x){Write-Host "> $x"-f 3};$r="Rainmeter";if($null=gps $r -ea 0){w "Shutdown <$r>...";saps "$env:PROGRAMFILES\$r\$r.exe" "!Quit";sleep 2};w "Uninstall <$r>...";saps "$env:PROGRAMFILES\$r\uninst.exe" "/S" -wait;w "Remove leftovers";"$env:APPDATA\$r","$env:USERPROFILE\Documents\$r"|ri -r -for;""
```