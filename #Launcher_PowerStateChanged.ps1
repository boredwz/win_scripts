#  #Launcher_PowerStateChanged (PowerShell)

$isCharging = (Get-CIMInstance Win32_Battery).BatteryStatus -ne 1
Set-Location $PSScriptRoot
$startStop = if ($isCharging) {"Start"} else {"Stop"}
$onOff = if ($isCharging) {"On"} else {"Off"}

& ".\Controls\BluetoothControl.ps1" $onOff
& ".\Apps\SyncTrayzor.ps1" $startStop
& ".\Apps\Spotify.ps1" $startStop -force