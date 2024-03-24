#  #ADM_scripts_Loader (PowerShell)
#  
#  [Author]
#    wvzxn | https://github.com/wvzxn

#requires -Version 5

param
(
    [ValidateSet(
        "TimeSwitchModule",
        "BatteryStatusChanged",
        "Manual",
        "SystemResume",
        "SystemUnlock")]
    [string]$Trigger,
    [switch]$Dark
)

$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

function RestartExplorer
{
    # $t=@();(New-Object -co Shell.Application).Windows()|%{$t+=$_.Document.Folder.Self.Path};kill -proc explorer -for;sleep 2;$t|%{start explorer $_ -win min}
    $openTabs = @()
    (New-Object -ComObject Shell.Application).Windows() | ForEach-Object { $openTabs += $_.Document.Folder.Self.Path }
    Stop-Process -ProcessName explorer -Force
    Start-Sleep 2
    $openTabs | ForEach-Object { Start-Process explorer.exe $_ -WindowStyle Minimized }
}

function Log($line)
{
    (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString() + " | " + $line | Out-File ".\$scriptName.log" -Append
}

Log " "
Log "================== Start ==================" | 
Log "Src: $Trigger"

RestartExplorer
#Start-Sleep 1

#   Run each script in the '#scripts' dir, except '#blabla.ps1'
$scripts = Get-ChildItem ".\*\Theme_*.ps1" -File
foreach ($script in $scripts)
{
    #   LOG: [script] + Arguments
    $arguments = "-ep bypass -file", ($script.fullname)
    if ($Dark) { $arguments += "-Dark"; Log "$($script.name) -Dark" } else { Log $script.name }
    Start-Process PowerShell -WindowStyle Hidden -ArgumentList $arguments
}

Remove-Item ".\$($scriptName)_lockfile"
Log "=================== End ==================="
return