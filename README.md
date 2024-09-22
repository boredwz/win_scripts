# Collection of Windows scripts



## Auto Dark Mode helper script

Auto Dark Mode allows you to switch between light and dark themes, but it causes OS interface artifacts. This script will help you get rid of them.

### Features

- Prevent ADM script multiple instance (lock file)  
- Restart `explorer.exe` and restore tabs  
- Launch external scripts  
- Refresh ADM theme to fix wallpaper not changing error (force theme toggle)  
- Restore last active window (ps\\foregroundWindow.ps1)

### Installation

#### Pre-setup

1. [Download](https://github.com/AutoDarkMode/Windows-Auto-Night-Mode) and install ADM
2. Enable automatic theme switching
3. Enable `Always refresh DWM on theme switch` in Settings

#### Automatic installation via PowerShell (recommended)

```powershell
"";function w($x){Write-Host "> $x"-f 3};cd $env:USERPROFILE;w "Removing old version and junk files...";gci -dir|?{($_.name -eq "win_scripts") -or ($_.name -eq "win_scripts-master")}|ri -rec -for;gci -file|?{$_.name -eq "m.zip"}|ri -rec -for;w "Downloading and installing win_scripts...";iwr https://github.com/boredwz/win_scripts/archive/refs/heads/master.zip -o m.zip;expand-archive m.zip -dest ".\";ri m.zip;ren win_scripts-master -n win_scripts;cd win_scripts\ps;w "Setting up ADM scripts.yaml...";$c=(gc adm_scripts.yaml) -replace 'C:\\\\\.\.CHANGE THIS\.\.\\\\win_scripts\\\\ps',((gl).Path -replace '\\','\\');$c -replace 'Enabled: false','Enabled: true'|sc $env:APPDATA\AutoDarkMode\scripts.yaml -for;""
```

- Use this code to _update_ or _re-install_
- Installation path: `%USERPROFILE%\win_scripts`

<br>

<details><summary><b>Manual installation</b></summary>

<br>

1. Clone this repository, or download and extract **[master.zip](https://github.com/boredwz/win_scripts/archive/refs/heads/master.zip)**
2. In `adm_scripts.yaml` change _WorkingDirectory_ to the `..\win_scripts\ps` folder
3. Rename `adm_scripts.yaml` -> `scripts.yaml`
4. Copy -> `%APPDATA%\AutoDarkMode\scripts.yaml`
5. Enable scripts in ADM settings

> `💡`&nbsp; Enable **Debug mode** in ADM Settings and check `service.log` for syntax errors. Look for this lines: `AdmConfigMonitor.OnChangedScriptConfig`

</details>

<br>

### Uninstallation

```powershell
"";function w($x){Write-Host "> $x"-f 3};$a="AutoDarkMode";if($null=gps "${a}Svc" -ea 0){w "Shutdown <$a>...";$aw=$true;$null=& "$env:LOCALAPPDATA\Programs\$a\adm-app\${a}Shell.exe" --exit;sleep 2};w "Remove <win_scripts> and reset <scripts.yaml>";"$env:USERPROFILE\win_scripts","$env:APPDATA\$a\scripts.yaml"|ri -r -for;w "Start <$a>";if($aw){saps "$env:LOCALAPPDATA\Programs\$a\adm-app\${a}Svc.exe"};""
```

#### OR

1. Exit ADM
2. Delete:
    - `%USERPROFILE%\win_scripts`
    - `%APPDATA%\AutoDarkMode\scripts.yaml`
3. Start ADM

<br>

### Command-line parameters

```
-<Parameter> [Value]
```

| Parameter | Values | Description |
|---|---|---|
| Theme | Light, Dark | Set theme, if not specified then Windows Theme will be used |
| Trigger | Any, TimeSwitchModule, NightLightTrackerModule,<br>BatteryStatusChanged, SystemResume, Manual,<br>ExternalThemeSwitch, Startup, SystemUnlock, Api | Set AutoDarkMode trigger |
| RestartMode | Normal, Minimized | Set explorer.exe restart mode |
| Restart |  | Force restart explorer.exe |
| NoAdmRefresh |  | Do not refresh ADM theme |
| NoScripts |  | Do not launch external scripts (ps\\_adm_helper\\\*.ps1) |
| NoActivate |  | Do not restore last active window (ps\\foreground_window.ps1) |

#### Examples

```powershell
# PowerShell
& ".\adm_helper.ps1" -Trigger TimeSwitchModule -Theme Dark -Restart
& ".\adm_helper.ps1" Light BatteryStatusChanged -NoScripts -NoActivate
& ".\adm_helper.ps1" -Restart -NoAdmRefresh

# VBScript
#  SYNTAX: /<Parameter>:[Value]
cscript //nologo "adm_helper.vbs" /theme:dark /trigger:Any /restartmode:minimized
```

<br>

###  VBScript alternative

> `⚠️`&nbsp; In October 2023, Microsoft announced that VBScript will be deprecated. In future releases of Windows, VBScript will be available as a Feature On Demand before its removal from the operating system.

Some _PowerShell_ scripts are duplicated in _Visual Basic (VBScript)_. They are designed for older PCs where the process of starting (initializing) _PowerShell_ is slower than _Windows Script Host_. This can be useful, for example, when restarting `explorer.exe`.

All the necessary information is contained in the files themselves as comments.

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