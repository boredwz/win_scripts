#  #Launcher_BatteryStatus (PowerShell)

$isCharging = (Get-CIMInstance Win32_Battery).BatteryStatus -ne 1
$startStop = if ($isCharging) {"Start"} else {"Stop"}
$onOff = if ($isCharging) {"On"} else {"Off"}
Set-Location $PSScriptRoot

& ".\BluetoothControl.ps1" $onOff; Start-Sleep -Milliseconds 250
& ".\SyncTrayzor.ps1" $startStop; Start-Sleep -Milliseconds 250
& ".\Spotify.ps1" $startStop -force; Start-Sleep -Milliseconds 250