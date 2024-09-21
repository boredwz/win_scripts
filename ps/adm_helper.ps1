#  adm_helper (PowerShell)
#  
#  [Author]
#    boredwz | https://github.com/boredwz
#  
#  [Info]
#    - Prevent ADM script multiple instance (lock file)
#    - Restart explorer.exe and restore tabs
#    - Launch external scripts
#    - Refresh ADM theme to fix wallpaper not changing error (force theme toggle)
#    - Restore last active window
#  
#  [Usage]
#    Command-line parameters:
#      [-Theme] — Specify <Light/Dark>, if not specified then Windows Theme will be used
#      [-Trigger] — Specify <ADM trigger name>
#      [-Restart] — Force restart explorer.exe
#      [-NoAdmRefresh] — Do not refresh ADM theme
#      [-NoScripts] — Do not launch external scripts (ps\_adm_helper\*.ps1)
#      [-NoActivate] — Do not restore active window (foreground_window.ps1)
#    
#    Examples:
#      & ".\adm_helper.ps1"
#      & ".\adm_helper.ps1" -Trigger TimeSwitchModule -Theme Dark -Restart
#      & ".\adm_helper.ps1" Light BatteryStatusChanged -NoScripts -NoActivate
#      & ".\adm_helper.ps1" -Restart -NoAdmRefresh

#requires -Version 5

param (
    [ValidateSet("Light","Dark")][Alias("th")][string]$Theme,
    [ValidateSet("Any","Api","BatteryStatusChanged","ExternalThemeSwitch","Manual",
        "NightLightTrackerModule","Startup","SystemResume","SystemUnlock",
        "TimeSwitchModule")][Alias("tr")][string]$Trigger,
    [Alias("noadm")][switch]$NoAdmRefresh,
    [Alias("noscr")][switch]$NoScripts,
    [Alias("noact")][switch]$NoActivate,
    [Alias("r","restart")][switch]$ForceRestart
)

class LockFile {
    [string]$Path
    [int]$TimeoutProcessId
    [int]$TimeoutSeconds = 30
    [bool]$EnableTimeout = $false

    LockFile([string]$path) {
        $this.Path = $path
    }

    [bool]Exists() {
        return Test-Path $this.Path -PathType Leaf
    }

    [void]Create() {
        $null = New-Item $this.Path -ItemType File -Force
        if ($this.EnableTimeout) {
            $Command = "sleep $($this.TimeoutSeconds);'$($this.Path)'|%{if(test-path `$_ -type leaf){ri `$_ -for}}"
            $this.TimeoutProcessId = (Start-Process powershell `
                -PassThru `
                -WindowStyle Hidden `
                -ArgumentList "-noni -nol -nop -ep bypass -c", $Command).Id
        }
    }

    [void]Delete() {
        if (Test-Path $this.Path -PathType Leaf) {
            $null = Remove-Item $this.Path -Force
        }
        if ($this.EnableTimeout) {
            Stop-Process -Id $this.TimeoutProcessId -Force -ErrorAction SilentlyContinue
        }
    }
}

function RestartExplorer {
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
}

function Log {
    param(
        [Parameter(ValueFromPipeline=$true)][string]$line,
        [alias("wo","without")][switch]$WithoutDate
    )
    $dateLine = if ($WithoutDate) {""} else {(Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString() + " | "}
    #(Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString() + " | " + $line | Out-File ".\$scriptName.log" -Append
    Write-Host ($dateLine + $line)
}

function IsWindowsThemeLight {
    $regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $themeValue = Get-ItemProperty -Path $regPath -Name "SystemUsesLightTheme" -ErrorAction SilentlyContinue
    return $themeValue.SystemUsesLightTheme -eq 1
}





Set-Location $PSScriptRoot

$lockFile = [LockFile]::New((Join-Path $PSScriptRoot "$($MyInvocation.MyCommand.Name)_lockfile"))
$lockFile.EnableTimeout = $true
if ($lockFile.Exists()) {return} else {$lockFile.Create()}

Log " " -WithoutDate
Log " " -WithoutDate
Log "[==== $($MyInvocation.MyCommand.Name) ====]"

$isThemeDark = if ($Theme) {$Theme -match "Dark"} else {-not (IsWindowsThemeLight)}
$strTheme = if ($isThemeDark) {"Dark"} else {"Light"}
$doRestart = (($Trigger -eq "BatteryStatusChanged") -and $isThemeDark) -or $ForceRestart
$doScripts = !$NoScripts
$doAdmRefresh = ((Get-Process AutoDarkModeSvc -ErrorAction SilentlyContinue).Count -ne 0) -and !$NoAdmRefresh
$doActivate = !$NoActivate

Log " Theme: $strTheme"
Log " Trigger: $Trigger"
Log " "



# Restart explorer.exe 5 sec
if ($doRestart) {
    # save current active window
    if ((Test-Path ".\foreground_window.ps1" -PathType Leaf) -and !$NoActivate) {
        $activeWindowId = (powershell.exe ".\foreground_window.ps1" -get)
    }

    Log " > Restart <explorer.exe> and restore tabs"
    if (Test-Path ".\restart_explorer.ps1" -PathType Leaf) {
        & ".\restart_explorer.ps1"
    } else {
        RestartExplorer
    }
}

# Run PS Theme scripts (.\_adm_helper\*.ps1)
if ($doScripts) {
    foreach ($script in (Get-ChildItem ".\_adm_helper\*.ps1" -File)) {
        $arguments = "-noni -nol -nop -ep bypass -f `"$($script.fullname)`" -$strTheme"
        Log " > Run '$($script.name)' -$strTheme"
        Start-Process PowerShell -WindowStyle Hidden -ArgumentList $arguments
    }
}

# Refresh ADM theme to fix wallpaper not changing error (force theme toggle)
if ($doAdmRefresh) {
    if (!$doRestart) {Start-Sleep 4}
    $admShellExe = "$env:LOCALAPPDATA\Programs\AutoDarkMode\adm-app\AutoDarkModeShell.exe"
    $admForceTheme = if ($isThemeDark) {"--force-dark"} else {"--force-light"}

    Log " > Refresh ADM theme (force theme toggle)"
    $null = & $admShellExe $admForceTheme
    Start-Sleep 2
    $null = & $admShellExe --no-force
}

# Restore last active window (foreground_window.ps1)
if ($doRestart -and $doActivate) {
    if (!$doAdmRefresh) {Start-Sleep 2}
    if ($activeWindowId) {
        if (powershell.exe ".\foreground_window.ps1" -set $activeWindowId) {
            Log " > Restore last active window (foreground_window.ps1)"
        }
    } else {
        Log " > (!)Last active window NOT restored (foreground_window.ps1)"
    }
}



$lockFile.Delete()

# Echo end
Log "[=====$(-join ('='*($MyInvocation.MyCommand.Name).Length))=====]"
Log " " -WithoutDate

return