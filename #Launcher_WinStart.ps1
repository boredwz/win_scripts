#   #Launcher_WinStart (PowerShell)

$isCharging = (Get-CIMInstance Win32_Battery).BatteryStatus -ne 1
Set-Location $PSScriptRoot

& ".\EQ APO (PhilipsOff + VolDown).lnk"
& ".\Rainmeter.lnk"
& ".\Sandboxie.lnk"
Start-Sleep -Seconds 3
& ".\AutoDarkMode.lnk"

if (!$isCharging)
{
    & ".\BluetoothControl.ps1" Off
    return
}

& ".\SyncTrayzor.ps1" Start
& ".\Spotify.ps1" Start