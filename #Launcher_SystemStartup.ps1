#   #Launcher_SystemStartup (PowerShell)

$isCharging = (Get-CIMInstance Win32_Battery).BatteryStatus -ne 1
#$itemArgs = if ($isCharging) {"+"} else {"-"}

Set-Location $PSScriptRoot

$files = Get-ChildItem | Where-Object { $_.Name -match "^[^\#].*\.(lnk|exe|ps1|cmd|bat|vbs)$" }

function Launcher ($gciFiles, $regex, $ms, $ar)
{
    $gciFiles | `
    Where-Object { $_.Name -match $regex } | `
    ForEach-Object { & $_.FullName $ar; Start-Sleep -Milliseconds $ms }
}

Launcher $files "^.*(?<!_END|_onlyAC)\.(lnk|exe)$" 500                                  # [*.<lnk/exe>]
#Launcher $files "^.*(?<!_END|_onlyAC)\.(ps1|cmd|bat|vbs)$" 250 $itemArgs                # [*.<ps1/cmd/bat/vbs>]
if ($isCharging) { Launcher $files "^.*_onlyAC\.(lnk|exe)$" 500 }                       # [_onlyAC.<lnk/exe>]
#if ($isCharging) { Launcher $files "^.*_onlyAC\.(ps1|cmd|bat|vbs)$" 250 $itemArgs }     # [_onlyAC.<ps1/cmd/bat/vbs>]

Start-Sleep -Seconds 5
Launcher $files "^.*(?<!_onlyAC)_END\.(lnk|exe)$" 500                                   # [_END.<lnk/exe>]
#Launcher $files "^.*(?<!_onlyAC)_END\.(ps1|cmd|bat|vbs)$" 250 $itemArgs                 # [_END.<ps1/cmd/bat/vbs>]
if ($isCharging) { Launcher $files "^.*_onlyAC_END\.(lnk|exe)$" 500 }                   # [_onlyAC_END.<lnk/exe>]
#if ($isCharging) { Launcher $files "^.*_onlyAC_END\.(ps1|cmd|bat|vbs)$" 250 $itemArgs } # [_onlyAC_END.<ps1/cmd/bat/vbs>]
