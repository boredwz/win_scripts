#   #Launcher_SystemStartup (PowerShell)

$isCharging = (Get-CIMInstance Win32_Battery).BatteryStatus -ne 1
Set-Location $PSScriptRoot
$files = Get-ChildItem | Where-Object { $_.Name -match "^[^\#].*\.(lnk|exe|ps1|cmd|bat|vbs)$" }

function Launcher ($gciFiles, $regex, $ms)
{
    $gciFiles | `
    Where-Object { $_.Name -match $regex } | `
    ForEach-Object { & $_.FullName; Start-Sleep -Milliseconds $ms }
}

Launcher $files "^.*(?<!_END|_onlyAC)\.(lnk|exe)$" 500                                  # [*.<lnk/exe>]
if ($isCharging) { Launcher $files "^.*_onlyAC\.(lnk|exe)$" 500 }                       # [_onlyAC.<lnk/exe>]
Start-Sleep -Seconds 5
Launcher $files "^.*(?<!_onlyAC)_END\.(lnk|exe)$" 500                                   # [_END.<lnk/exe>]

if ($isCharging) { & ".\SyncTrayzor.ps1" Start }
if ($isCharging) { & ".\Spotify.ps1" Start }