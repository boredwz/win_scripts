#  #Launcher_PowerStateChanged (PowerShell)

$isCharging = (Get-CIMInstance Win32_Battery).BatteryStatus -ne 1
Set-Location $PSScriptRoot
$startStop = if ($isCharging) {"Start"} else {"Stop"}
$onOff = if ($isCharging) {"On"} else {"Off"}

& ".\BluetoothControl.ps1" $onOff
& ".\SyncTrayzor.ps1" $startStop
& ".\Spotify.ps1" $startStop -force