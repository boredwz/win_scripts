#  SyncTrayzor [Open/Close] (PowerShell)

param
(
    [Parameter(Mandatory=$true)][ValidateSet('Open', '+', 'Close', '-')]
    [string]$Status,
    [switch]$Force
)

$exePath = "$env:PROGRAMFILES\SyncTrayzor\synctrayzor.exe"
$exeArgs = if ($Status -match "Open|\+") { "--minimized" } else { "--shutdown" }
. $exePath $exeArgs