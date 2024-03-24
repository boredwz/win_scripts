param([ValidateSet("Start", "Stop")][string]$Command = "Start",[switch]$Force)

$gps = Get-Process -Name "SyncTrayzor" -ErrorAction SilentlyContinue

if ($Command -match "Start")
{
	if ($gps) { return }
    Start-Process "$env:PROGRAMFILES\SyncTrayzor\synctrayzor.exe" `
        -WorkingDirectory "$env:PROGRAMFILES\SyncTrayzor" `
        -ArgumentList "--minimized"
}
else
{
    Start-Process "$env:PROGRAMFILES\SyncTrayzor\synctrayzor.exe" `
        -WorkingDirectory "$env:PROGRAMFILES\SyncTrayzor" `
        -ArgumentList "--shutdown"
}