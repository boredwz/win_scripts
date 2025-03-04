<#
.SYNOPSIS
Restart <explorer.exe> and restore tabs

.DESCRIPTION
[Author]
  boredwz | https://github.com/boredwz

[Description]
  Tested:
    - Windows 10 (build 19045.4780)
    - PowerShell v5.1
  
  <!>
    It is not possible to open a single explorer window with multiple tabs on Windows 11.
    But you can use this tool as a workaround:
    https://github.com/w4po/ExplorerTabUtility
  
[One-liner] Respectively:
  $e='explorer';$t=@();(New-Object -co Shell.Application).Windows()|%{$t+=@{p=$_.Document.Folder.Self.Path;w=if($_.Top -lt 0){if($_.Top -lt -8000){'min'}else{'max'}}else{'nor'}}};kill -n $e -for;sleep 1;if(!($null=ps $e -ea 0)){saps $e};sleep 5;$t|%{sleep -m 500;saps $_.p -win $_.w}

[One-liner] Minimized:
  $e='explorer';$t=@();(New-Object -co Shell.Application).Windows()|%{$t+=$_.Document.Folder.Self.Path};kill -n $e -for;sleep 1;if(!($null=ps $e -ea 0)){saps $e};sleep 5;$t|%{sleep -m 500;saps $_ -win min}

.PARAMETER Minimize
Any window state -> Minimized.
Aliases: [-M], [-Min], [-Minimize], [-Minimized].

.EXAMPLE
PS C:\> & ".\RestartExplorer.ps1"
*explorer.exe restarting...*
*tabs restoring...*

.EXAMPLE
PS C:\> & ".\RestartExplorer.ps1" -minimized
*explorer.exe restarting...*
*tabs restoring minimized...*
#>

param(
    [Alias("m","min","minimized")][switch]$Minimize
)

# Get explorer windows
$explorerWindows = @()
(New-Object -ComObject Shell.Application).Windows() | ForEach-Object {
    $windowState = 'Normal'
    if($_.Top -lt 0) {$windowState = 'Maximized'}
    if($_.Top -lt -8000 -or $Minimize) {$windowState = 'Minimized'}
    $explorerWindows += @{
        Location=$_.Document.Folder.Self.Path;
        WindowState=$windowState
    }
}

# Restart explorer.exe
Stop-Process -ProcessName explorer -Force
Start-Sleep 1
if (!($null = Get-Process explorer -ErrorAction SilentlyContinue)) {Start-Process explorer}
Start-Sleep -m 5000

# Open saved explorer windows
$explorerWindows | ForEach-Object {
    Start-Sleep -m 500
    Start-Process $_.Location -WindowStyle $_.WindowState
}