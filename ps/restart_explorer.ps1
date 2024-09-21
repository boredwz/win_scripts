<#
.SYNOPSIS
Restart <explorer.exe> and restore tabs

.DESCRIPTION
[Author]
  boredwz | https://github.com/boredwz

[URL]
  Gist | https://gist.github.com/boredwz/1511cb7f81f0c01f3373a3d2ad8a7e9d

[Info]
  Tested on:
  - Windows 10 (build 19045.4780)
  - PowerShell v5.1

  🔔 I don't know if it is possible to open a single window with multiple tabs on Windows 11.
  
  Restart <explorer.exe> and restore tabs:
    1. Respectively (save tab state)
      Normal -> Normal
      Maximized -> Maximized
      Minimized -> Normalized and Minimized
    2. Minimized
      Any -> Minimized
  
[One-liner] Respectively:
  $e='explorer';$t=@();(New-Object -co Shell.Application).Windows()|%{$t+=@{p=$_.LocationURL;w=if($_.Top -lt 0){if($_.Top -lt -8000){'min'}else{'max'}}else{'nor'}}};kill -n $e -for;sleep 1;if(!($null=ps $e -ea 0)){saps $e};sleep 4;$t|%{saps $_.p -win $_.w}

[One-liner] Minimized:
  $e='explorer';$t=@();(New-Object -co Shell.Application).Windows()|%{$t+=$_.LocationURL};kill -n $e -for;sleep 1;if(!($null=ps $e -ea 0)){saps $e};sleep 4;$t|%{saps $_ -win min}

.PARAMETER Minimize
Any window state -> Minimized.
Aliases: "Min", "Minimize", "Minimized".

.EXAMPLE
PS C:\> & ".\RestartExplorer"
*explorer.exe restarting...*
*tabs restoring...*

.EXAMPLE
PS C:\> & ".\RestartExplorer" -minimized
*explorer.exe restarting...*
*tabs restoring minimized...*
#>

param(
    [Alias("min","minimized")][switch]$Minimize
)

# Get explorer windows
$explorerWindows = @()
(New-Object -ComObject Shell.Application).Windows() | ForEach-Object {
    $windowState = 'Normal'
    if($_.Top -lt 0) {$windowState = 'Maximized'}
    if($_.Top -lt -8000 -or $Minimize) {$windowState = 'Minimized'}
    $explorerWindows += @{
        Location=$_.LocationURL;
        WindowState=$windowState
    }
}

# Restart explorer.exe
Stop-Process -ProcessName explorer -Force
Start-Sleep 1
if (!($null = Get-Process explorer -ErrorAction SilentlyContinue)) {Start-Process explorer}
Start-Sleep 4

# Open saved explorer windows
$explorerWindows | ForEach-Object {
    Start-Process $_.Location -WindowStyle $_.WindowState
}