#   #Launcher_WinStart (PowerShell)

$onBattery = (Get-CIMInstance Win32_Battery).BatteryStatus -eq 1

if(!($null = Get-Process AutoDarkModeSvc -ErrorAction SilentlyContinue)) {
    Set-Location "$env:LOCALAPPDATA\Programs\AutoDarkMode\adm-app"
    Start-Process ".\AutoDarkModeSvc.exe"
}

Start-Sleep -Seconds 10


if(!($null = Get-Process Rainmeter -ErrorAction SilentlyContinue)) {
    Set-Location "$env:PROGRAMFILES\Rainmeter"
    Start-Process ".\Rainmeter.exe"
}

if(!($null = Get-Process Lightshot -ErrorAction SilentlyContinue)) {
    Set-Location "${env:ProgramFiles(x86)}\Skillbrains\lightshot" 
    Start-Process ".\Lightshot.exe"
}


if (!$onBattery)
{
    Start-Sleep -Seconds 2
    if(!($null = Get-Process SyncTrayzor -ErrorAction SilentlyContinue)) {
        Set-Location "$env:PROGRAMFILES\SyncTrayzor"
        Start-Process ".\synctrayzor.exe" -ArgumentList "--minimized"
    }
}