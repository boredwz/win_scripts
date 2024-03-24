# Collection of Windows scripts

## Dark Theme scripts

Using AutoDarkMode and my script launcher, you can set application themes that don't adapt to the Windows system theme.

### Usage

**1. Install [AutoDarkMode](https://github.com/AutoDarkMode/Windows-Auto-Night-Mode)**

**2. Clone the repository, or download [**master.zip**](https://github.com/wvzxn/win_scripts/archive/refs/heads/master.zip)**

**3. Setting up ADM scripts:**

- Copy the code of `scripts.yaml` below and change `WorkingDirectory:` property to the cloned repo path
- Save as `%APPDATA%\AutoDarkMode\scripts.yaml`
- Enable scripts in ADM

<details><summary><b><code>scripts.ps1</code></b></summary>

```yaml
Enabled: false
Component:
  Scripts:
  - Name: Launcher_ADM.vbs (TimeSwitchModule)
    Command: cscript
    WorkingDirectory: >>CHANGE THIS<<
    ArgsLight: ['#Launcher_ADM.vbs', TimeSwitchModule]
    ArgsDark: ['#Launcher_ADM.vbs', TimeSwitchModule, -Dark]
    AllowedSources: [TimeSwitchModule]
  - Name: Launcher_ADM.vbs (BatteryStatusChanged)
    Command: cscript
    WorkingDirectory: >>CHANGE THIS<<
    ArgsLight: ['#Launcher_ADM.vbs', BatteryStatusChanged]
    ArgsDark: ['#Launcher_ADM.vbs', BatteryStatusChanged, -Dark]
    AllowedSources: [BatteryStatusChanged]
  - Name: Launcher_ADM.vbs (Manual)
    Command: cscript
    WorkingDirectory: >>CHANGE THIS<<
    ArgsLight: ['#Launcher_ADM.vbs', Manual]
    ArgsDark: ['#Launcher_ADM.vbs', Manual, -Dark]
    AllowedSources: [Manual]
  - Name: Launcher_ADM.vbs (SystemResume)
    Command: cscript
    WorkingDirectory: >>CHANGE THIS<<
    ArgsLight: ['#Launcher_ADM.vbs', SystemResume]
    ArgsDark: ['#Launcher_ADM.vbs', SystemResume, -Dark]
    AllowedSources: [SystemResume]
  - Name: Launcher_ADM.vbs (SystemUnlock)
    Command: cscript
    WorkingDirectory: >>CHANGE THIS<<
    ArgsLight: ['#Launcher_ADM.vbs', SystemUnlock]
    ArgsDark: ['#Launcher_ADM.vbs', SystemUnlock, -Dark]
    AllowedSources: [SystemUnlock]
```

</details>

## Screenshots

![YF2](./Screenshots/Theme_YF2.jpg)

## Addons

### Silent Uninstallers

#### AutoDarkMode

```powershell
$ErrorActionPreference="SilentlyContinue";$a="AutoDarkMode";"$env:LOCALAPPDATA\Programs\$a"|`
%{start "$_\adm-app\$($a)Shell.exe" "--exit" -win min -wait;sleep 2;start "$_\unins000.exe" "/VERYSILENT" -wait};`
"$env:APPDATA\$a"|ri -rec -for
```

#### Rainmeter

```powershell
$ErrorActionPreference="SilentlyContinue";$r="Rainmeter";"$env:PROGRAMFILES\$r"|`
%{start "$_\$r.exe" "!Quit";sleep 2;start "$_\uninst.exe" "/S" -wait};`
"$env:APPDATA\$r","$env:USERPROFILE\Documents\$r"|ri -rec -for
```
