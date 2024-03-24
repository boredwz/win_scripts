#   #Launcher_WinStart (PowerShell)

$isCharging = (Get-CIMInstance Win32_Battery).BatteryStatus -ne 1
Set-Location $PSScriptRoot

& "$env:PROGRAMFILES\EqualizerAPO\config\#EQ.vbs" -PhilipsOff -VolumeDown
& "$env:PROGRAMFILES\Rainmeter\Rainmeter.exe"
& "$env:PROGRAMFILES\Sandboxie\SbieCtrl.exe"
Start-Sleep -Seconds 8
& "$env:LOCALAPPDATA\Programs\AutoDarkMode\adm-app\AutoDarkModeSvc.exe"

if (!$isCharging)
{
    & ".\Controls\BluetoothControl.ps1" Off
    return
}

& ".\Apps\SyncTrayzor.ps1" Start
& ".\Apps\Spotify.ps1" Start