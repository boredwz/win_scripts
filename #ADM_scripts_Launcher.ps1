#  #ADM_scripts_Loader (PowerShell)
#  
#  [Author]
#    wvzxn | https://github.com/wvzxn

#requires -Version 5

param
(
    [switch]$Dark,
    [switch]$TimeSwitchModule,
    [switch]$BatteryStatusChanged,
    [switch]$Manual,
    [switch]$SystemResume,
    [switch]$SystemUnlock
)



function CheckMulti ([switch]$Exit)
{
    $lock = ".\#ADM_scripts_Launcher_lock"

    if ($Exit)
    {
        Remove-Item $lock -Force -ErrorAction SilentlyContinue
        return
    }

    if (Test-Path $lock)
    {
        return $true
    }
    else
    {
        "#scripts_loader is running..." | Set-Content $lock
        attrib.exe +r $lock
        return $false
    }
}

function PreventDoubleInstance ([switch]$Output)
{
    try { $scriptFileName = split-path $MyInvocation.PSCommandPath -Leaf } catch { $scriptFileName = $Null }
    try
    {
        [Array]$psProcesses = @(Get-WmiObject Win32_Process -Filter "name like '%Powershell.exe%' and handle != '$pid'" | Where-Object {$_})
    }
    catch { Throw }
    if ($psProcesses.Count -gt 0)
    {
        foreach ($psProcess in $psProcesses)
        {
            if ($psProcess.CommandLine -like "*$scriptFileName*" -and $scriptFileName)
            {
                if ($Output) { "== Found a PS process running this script, trying to kill..." }
                try { Stop-Process -Id $psProcess.Handle -Force -Confirm:$False } catch { Throw }
            }
        }
    }
}

function RestartExplorer
{
    # $t=@();(New-Object -co Shell.Application).Windows()|%{$t+=$_.Document.Folder.Self.Path};kill -proc explorer -for;sleep 2;$t|%{start explorer $_ -win min}
    $openTabs = @()
    (New-Object -ComObject Shell.Application).Windows() | ForEach-Object { $openTabs += $_.Document.Folder.Self.Path }
    Stop-Process -ProcessName explorer -Force
    Start-Sleep 2
    $openTabs | ForEach-Object { Start-Process explorer.exe $_ -WindowStyle Minimized }
}



" "
"================== Start =================="

#   LOG: Source (Trigger)
if ($TimeSwitchModule) { "Src: TimeSwitchModule" }
if ($BatteryStatusChanged) { "Src: BatteryStatusChanged" }
if ($Manual) { "Src: Manual" }
if ($SystemResume) { "Src: SystemResume" }
if ($SystemUnlock) { "Src: SystemUnlock" }

Start-Sleep -Milliseconds 500

#   LOG: Doubled instance check v1 (Lock file check), if true then exit
if (CheckMulti) { "================== Multi =================="; return }

#   LOG: Doubled instance check v2 (Find PS process), if true then try to exit
PreventDoubleInstance -Output

RestartExplorer
Start-Sleep 3

#   Run each script in the '#scripts' dir, except '#blabla.ps1'
if ($Dark) { $scriptArgs = " -Dark" }
$scripts = Get-ChildItem ".\*\Theme_*.ps1" -File
foreach ($script in $scripts)
{
    Start-Process PowerShell -Wait -WindowStyle Hidden `
        -ArgumentList "-ExecutionPolicy Bypass -File", ($script.fullname + $scriptArgs)
    
    #   LOG: [script] + Arguments
    "[#scripts\$($script.name)]" + $scriptArgs
}

#   Reset Doubled instance check v1 (Remove lock file)
CheckMulti -Exit

"=================== End ==================="
return