#  Bluetooth [On/Off/Toggle] (PowerShell)
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
    $null = $netTask.Wait(-1)
    $netTask.Result
}

if ((Get-Service bthserv -ea 0).Status -eq 'Stopped') { Start-Service bthserv }
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

$null = [Windows.Devices.Radios.Radio,Windows.System.Devices,ContentType=WindowsRuntime]
$null = [Windows.Devices.Radios.RadioAccessStatus,Windows.System.Devices,ContentType=WindowsRuntime]
$null = Await ([Windows.Devices.Radios.Radio]::RequestAccessAsync()) ([Windows.Devices.Radios.RadioAccessStatus])
$radios = Await ([Windows.Devices.Radios.Radio]::GetRadiosAsync()) ([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]])
$bluetooth = $radios | Where-Object { $_.Kind -eq 'Bluetooth' }
$null = [Windows.Devices.Radios.RadioState,Windows.System.Devices,ContentType=WindowsRuntime]
if ($Status -ne "Toggle") { $BluetoothStatus = $Status }
else { $BluetoothStatus = if ($bluetooth.State -match "Off") {"On"} else {"Off"} }
$null = Await ($bluetooth.SetStateAsync($BluetoothStatus)) ([Windows.Devices.Radios.RadioAccessStatus])
