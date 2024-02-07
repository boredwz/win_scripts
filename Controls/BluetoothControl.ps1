#  BluetoothControl [On/Off] (PowerShell)

param
(
    [ValidateSet('On', 'Off')]
    [string]$Status,
    [switch]$Force
)

$deviceList = `
"SRS-XB20",
"Soundcore Life Note"

function IsAnyBluetoothDeviceConnected ([string[]]$Name)
{
    return `
        (Get-PnpDevice -Class Bluetooth | `
            Where-Object { $Name -contains $_.FriendlyName } | `
            Get-PnpDeviceProperty | `
            Where-Object { $_.KeyName -match "{83DA6326-97A6-4088-9453-A1923F573B29} 15" } `
        ).Data -contains $true
}

function Set-Bluetooth  # On, Off, Toggle
{
    #   https://gist.githubusercontent.com/wvzxn/b8fa86d2a2de46007abbc992044070fe/raw/Set-Bluetooth.ps1
    
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet('On', 'Off', 'Toggle')]
        [string]$Status
    )
    
    function Await($WinRtTask, $ResultType)
    {
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1) | Out-Null
        $netTask.Result
    }
    
    if ((Get-Service bthserv).Status -eq 'Stopped') { Start-Service bthserv }
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $asTaskGeneric = `
    (
        [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object `
        {
              $_.Name -eq 'AsTask' `
                -and $_.GetParameters().Count -eq 1 `
                -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' `
        }
    )[0]
    
    [Windows.Devices.Radios.Radio,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null
    [Windows.Devices.Radios.RadioAccessStatus,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null
    Await ([Windows.Devices.Radios.Radio]::RequestAccessAsync()) ([Windows.Devices.Radios.RadioAccessStatus]) | Out-Null
    $radios = Await ([Windows.Devices.Radios.Radio]::GetRadiosAsync()) ([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]])
    $bluetooth = $radios | Where-Object { $_.Kind -eq 'Bluetooth' }
    [Windows.Devices.Radios.RadioState,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null
    if ($Status -ne "Toggle") { $BluetoothStatus = $Status }
    else { $BluetoothStatus = if ($bluetooth.State -match "Off") {"On"} else {"Off"} }
    Await ($bluetooth.SetStateAsync($BluetoothStatus)) ([Windows.Devices.Radios.RadioAccessStatus]) | Out-Null
}

if ($Status -match "On") {Set-Bluetooth On}
else
{
    if (IsAnyBluetoothDeviceConnected $deviceList) { return }
    Set-Bluetooth Off
}