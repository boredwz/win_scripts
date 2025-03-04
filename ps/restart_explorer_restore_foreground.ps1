param([Alias("m","min","minimized")][switch]$Minimize)

$fore_url = "https://github.com/boredwz/win_scripts/blob/master/ps/foreground_window.ps1?raw=1"
$rest_url = "https://github.com/boredwz/win_scripts/blob/master/ps/restart_explorer.ps1?raw=1"
$fore_exists = Test-Path ".\foreground_window.ps1" -PathType Leaf
$rest_exists = Test-Path ".\restart_explorer.ps1" -PathType Leaf
if ($Minimize) {$rest_arg = "-Minimize"}

$activeWindowId = `
    if ($fore_exists) {
        (& ".\foreground_window.ps1" -get)
    } else {
        Invoke-Expression "&{$(Invoke-WebRequest -useb $fore_url)} -Get"
    }

'{0} | restart' -f (get-date -f "hh:mm:ss.fff")
if ($rest_exists) {
    & ".\restart_explorer.ps1" $rest_arg
} else {
    Invoke-Expression "&{$(Invoke-WebRequest -useb $rest_url)} $rest_arg"
}

Start-Sleep 4
'{0} | restore foreground window' -f (get-date -f "hh:mm:ss.fff")
$null = (& ".\foreground_window.ps1" -set $activeWindowId)