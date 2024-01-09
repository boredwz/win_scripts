#  #Launcher_BatteryStatus (PowerShell)

$isCharging = (Get-CIMInstance Win32_Battery).BatteryStatus -ne 1
$itemArgs = if ($isCharging) {"+"} else {"-"}

Set-Location $PSScriptRoot

$toExecute = Get-ChildItem | Where-Object { $_.Name -match "^[^\#].*\.(lnk|exe|ps1|cmd|bat|vbs)$" }
$toExecute | Where-Object { $_.Extension -match "^\.(lnk|exe)$" } | ForEach-Object { . $_.FullName $itemArgs; Start-Sleep -Milliseconds 500 }
$toExecute | Where-Object { $_.Extension -notmatch "^\.(lnk|exe)$" } | ForEach-Object { . $_.FullName $itemArgs; Start-Sleep -Milliseconds 250 }