#  SyncTrayzor Start/Shutdown (PowerShell)

param ([switch]$Shutdown)

$syncTrayzor = "$env:PROGRAMFILES\SyncTrayzor\synctrayzor.exe"
$syncTrayzorArgs = if ($Shutdown) { "--shutdown" } else { "--minimized" }
. $syncTrayzor $syncTrayzorArgs