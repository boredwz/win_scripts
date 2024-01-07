#  SyncTrayzor Start/Quit (PowerShell)

param
(
    [switch]$Quit
)

$syncTrayzor = "$env:PROGRAMFILES\SyncTrayzor\synctrayzor.exe"
$syncTrayzorArgs = if ( $Quit ) { "--shutdown" } else { "--minimized" }
. $syncTrayzor $syncTrayzorArgs