#  Spotify [Open/Close] (PowerShell)

param
(
    [Parameter(Mandatory=$true)][ValidateSet('Open', '+', 'Close', '-')]
    [string]$Status,
    [switch]$Force
)

$exePath = "$env:APPDATA\Spotify\spotify.exe"

if ($Status -match "Open|\+") { . $exePath }
else
{
    Get-Process -Name "Spotify" | ForEach-Object { $_.CloseMainWindow() }
    Start-Sleep -Seconds 1
    if ($Force) { Stop-Process -Name "Spotify" -Force }
}