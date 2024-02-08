#   #Launcher_SystemStartup (PowerShell)

$isCharging = (Get-CIMInstance Win32_Battery).BatteryStatus -ne 1
Set-Location $PSScriptRoot

& ".\EQ APO (PhilipsOff + VolDown).lnk"
& ".\Rainmeter.lnk"
& ".\Sandboxie.lnk"
Start-Sleep -Seconds 3
& ".\AutoDarkMode.lnk"

if (!$isCharging) { return }

& ".\SyncTrayzor.ps1" Start
& ".\Spotify.ps1" Start