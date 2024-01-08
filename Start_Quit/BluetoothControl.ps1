#  Bluetooth Devices Start/Shutdown (PowerShell)

param ([switch]$Shutdown)

$deviceList = `
"SRS-XB20",
"Soundcore Life Note"

$btGist = "https://gist.githubusercontent.com/wvzxn/b8fa86d2a2de46007abbc992044070fe/raw/Bluetooth.ps1"

function IsAnyBluetoothDeviceConnected ([string[]]$Name)
{
    return `
        (Get-PnpDevice -Class Bluetooth | `
            Where-Object { $Name -contains $_.FriendlyName } | `
            Get-PnpDeviceProperty | `
            Where-Object { $_.KeyName -match "{83DA6326-97A6-4088-9453-A1923F573B29} 15" } `
        ).Data -contains $true
}

$onOff = "On"

if ($Shutdown)
{
    if (IsAnyBluetoothDeviceConnected $deviceList) { return }
    $onOff = "Off"
}

"$PSScriptRoot\#Bluetooth.ps1" | ForEach-Object `
{
    if (Test-Path $_) { . $_ $onOff }
    else { . $([scriptblock]::Create((New-Object Net.WebClient).DownloadString($btGist))) $onOff }
}