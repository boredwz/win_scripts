#  qBittorrent Theme Change (PowerShell)
#  
#  [Author]
#    wvzxn | https://github.com/wvzxn
#  
#  [Credits]
#    qBittorrent | https://github.com/qbittorrent/qBittorrent
#  
#  [Description]
#    The script enables <custom UI Theme> and then restarts qBittorrent.
#  
#  [Usage]
#    1. Download any dark theme and put somewhere
#    2. Open qBittorrent Settings
#    3. Select custom UI Theme
#    4. Uncheck "Show qBittorrent in notification area"
#       and "Confirmation on exit when torrents are active"
#    
#    Examples:
#      PowerShell> . ".\qBittorrent.ps1"; & ".\qBittorrent.ps1" -Dark
#      CMD> powershell -ep bypass -f "qBittorrent.ps1" -Dark

param
(
    [switch]$Dark
)

$qBTPath = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\qBittorrent" -ErrorAction SilentlyContinue)."Installlocation"
if ( !$qBTPath ) { $qBTPath = "$env:PROGRAMFILES\qBittorrent" }
if ( !(Test-Path "$qBTPath\qbittorrent.exe") ) { return }

$ini = "$env:APPDATA\qBittorrent\qBittorrent.ini"
$useCustomUITheme = if ( $Dark ) { "true" } else { "false" }
$process = Get-Process "qbittorrent" -ErrorAction SilentlyContinue

#   Exit existing qBittorent app
if ($process)
{
    [void]$process.CloseMainWindow()
    for ($i = 0; ($i -lt 30) -and (!$process.HasExited); $i++) { Start-Sleep -m 500 }
    $restart = $true
}

#   Ini edit and qBittorrent start
(Get-Content $ini) -replace "^(General\\UseCustomUITheme=).*`$","`${1}$useCustomUITheme" | Set-Content "$ini"
if ($restart) { Start-Process "$qBTPath\qbittorrent.exe" }