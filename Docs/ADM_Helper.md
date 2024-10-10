# Auto Dark Mode helper script

Auto Dark Mode allows you to switch between light and dark themes, but it causes OS interface artifacts. This script will help you get rid of them.

## Features

- Prevent ADM script multiple instance (lock file)  
- Restart `explorer.exe` and restore tabs  
- Launch external scripts  
- Refresh ADM theme to fix wallpaper not changing error (force theme toggle)  
- Restore last active window (ps\\foregroundWindow.ps1)

## Installation

### Pre-setup

1. [Download](https://github.com/AutoDarkMode/Windows-Auto-Night-Mode) and install ADM
2. Enable automatic theme switching
3. Enable `Always refresh DWM on theme switch` in Settings

### Automatic via PowerShell (recommended)

Customize installation directory — `$installDir`

- **Install**

  ```powershell
  $installDir = "$env:USERPROFILE"; `
  $installerUrl = "https://raw.githubusercontent.com/boredwz/win_scripts/master/ps/adm_helper_installer.ps1"; `
  & $([scriptblock]::Create((iwr -useb $installerUrl))) $installDir
  ```

- **Update**

  ```powershell
  $installDir = "$env:USERPROFILE"; `
  $installerUrl = "https://raw.githubusercontent.com/boredwz/win_scripts/master/ps/adm_helper_installer.ps1"; `
  & $([scriptblock]::Create((iwr -useb $installerUrl))) $installDir -Update
  ```

- **Uninstall**

  ```powershell
  $installDir = "$env:USERPROFILE"; `
  $installerUrl = "https://raw.githubusercontent.com/boredwz/win_scripts/master/ps/adm_helper_installer.ps1"; `
  & $([scriptblock]::Create((iwr -useb $installerUrl))) $installDir -Uninstall
  ```

### Manual

> [!TIP]
> Enable **Debug mode** in ADM Settings and check `service.log` for syntax errors. Look for lines like this: `AdmConfigMonitor.OnChangedScriptConfig`

- **Install**

  1\.&nbsp; Clone this repository, or download and extract **[master.zip](https://github.com/boredwz/win_scripts/archive/refs/heads/master.zip)**  
  2\.&nbsp; In `adm_scripts.yaml` change _WorkingDirectory_ to the `.\win_scripts\ps` folder  
  3\.&nbsp; Rename `adm_scripts.yaml` -> `scripts.yaml`  
  4\.&nbsp; Copy -> `%APPDATA%\AutoDarkMode\scripts.yaml`  
  5\.&nbsp; Enable scripts in ADM settings


- **Uninstall**

  1\.&nbsp; Exit ADM  
  2\.&nbsp; Delete `%USERPROFILE%\win_scripts` and `%APPDATA%\AutoDarkMode\scripts.yaml`  
  3\.&nbsp; Start ADM

<br>

## Command-line parameters

```powershell
& adm_helper.ps1 -<Parameter> [Value]
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

<br>

## Examples

```powershell
# PowerShell
& ".\adm_helper.ps1" -Trigger TimeSwitchModule -Theme Dark -Restart
& ".\adm_helper.ps1" Light BatteryStatusChanged -NoScripts -NoActivate
& ".\adm_helper.ps1" -Restart -NoAdmRefresh

# VBScript
#  SYNTAX: /<Parameter>[:Value]
cscript //nologo "adm_helper.vbs" /theme:dark /trigger:Any /restartmode:minimized /restart
```

<br>

##  VBScript alternative

> [!WARNING]
> In October 2023, Microsoft announced that VBScript will be deprecated. In future releases of Windows, VBScript will be available as a Feature On Demand before its removal from the operating system.

Some _PowerShell_ scripts are duplicated in _Visual Basic (VBScript)_. They are designed for older PCs where the process of starting (initializing) _PowerShell_ is slower than _Windows Script Host_. This can be useful, for example, when restarting `explorer.exe`.

All the necessary information is contained in the files themselves as comments.

<br>