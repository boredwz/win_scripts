#  YourFlyouts2 (Win11 Skin) (PowerShell)https://github.com/wvzxn/YourFlyouts/zipball/main
#  
#  [Author]
#    wvzxn | https://github.com/wvzxn
#  
#  [Credits]
#    Rainmeter    | https://www.rainmeter.net
#    YourFlyouts2 | https://github.com/Jax-Core/YourFlyouts
#  
#  [Description]
#    The script:
#      1. Checks for Rainmeter and YF2 installed
#      2. If not then prompts for download and install
#      3. Sets Win11 skin to light/dark
#    Accent color is imported from the system.
#  
#  [Usage]
#    Run with parameter -Dark to set to dark, or without to set to light.
#    Examples:
#      PowerShell> . ".\YF2_W11.ps1"; & ".\YF2_W11.ps1" -Dark
#      CMD> powershell -ep bypass -f "YF2_W11.ps1" -Dark

#Requires -PSEdition Desktop
#Requires -Version 5

param
(
    [switch]$Dark
)



function ImportFuncs
{
    #   Get-GithubLatestRelease.ps1
    Invoke-WebRequest -UseBasicParsing `
    "https://gist.githubusercontent.com/wvzxn/e7872773f4c44671ca37fad7ca3912b7/raw/Get-GithubLatestRelease.ps1" | `
    Invoke-Expression
}
function msgBox
{
    param
    (
        [string]$Title,
        [string]$Description
    )

    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $msgButton = "YesNo"
    $msgImage = "Question"
    $msgBoxResult = [System.Windows.MessageBox]::Show($Description,$Title,$msgButton,$msgImage)
    return $msgBoxResult -like "Yes"
}

function CheckInternetConnection
{
    return (Test-Connection "www.google.com" -Count 2 -Quiet)
}

function EditIniValues
{
    param
    (
        [string]$Path,
        [string[]]$PropsValues
    )

    if ( !(Test-Path $Path) ) { return }

    $text = Get-Content $Path
    for ($i = 0; $i -lt $PropsValues.Count; $i+=2)
    {
        $a = $PropsValues[$i]
        $b = $PropsValues[$i+1]
        if ($a -eq "") {$a = "[^;]\w+?"}
        $text = $text -replace "^($a\=).*`$","`${1}$b"
    }
    $text | Set-Content $Path
    Start-Sleep 1
}

function RMInstaller
{
    $exePath = Join-Path $env:PROGRAMFILES "Rainmeter\Rainmeter.exe"

    #   Download
    $installerPath = Join-Path $env:TMP (Get-GithubLatestRelease "rainmeter" "rainmeter" ".exe" -getname)
    Get-GithubLatestRelease "rainmeter" "rainmeter" ".exe" -dl -dest $env:TMP
    
    #   Install
    Start-Process $installerPath "/S" -Wait
    Remove-Item $installerPath -Force

    #   Start Rainmeter.exe
    if ( !(Get-Process 'rainmeter' -ErrorAction SilentlyContinue) ) { Start-Process $exePath; Start-Sleep 2 }

    #   Rainmeter Cleanup
    "Clock", "Disk", "System", "Welcome" | ForEach-Object {
        Start-Process $exePath "!DeactivateConfig", "illustro\$_"
        Start-Sleep -Milliseconds 500
    }
    Start-Process $exePath "!Quit"
    Start-Sleep -Milliseconds 500
    $ini = Join-Path $env:APPDATA "Rainmeter\Rainmeter.ini"
    (Get-Content $ini) -replace `
        "(SkinPath\=.+?)`$", `
        "`$1`nHardwareAcceleration=1`nDisableAutoUpdate=1`nDisableVersionCheck=1" | `
        Set-Content $ini
    Start-Sleep 1
    Start-Process $exePath; Start-Sleep 1
}

function YFInstaller
{
    #   Download
    $name = Get-GithubLatestRelease "wvzxn/YourFlyouts" -zip -getname
    Get-GithubLatestRelease "wvzxn/YourFlyouts" -zip -dl -dest $env:TMP

    #   Manual Install
    Expand-Archive (Join-Path $env:TMP $name) $env:TMP
    Remove-Item (Join-Path $env:TMP $name) -Force
    $dir = (Get-ChildItem $env:TMP -Filter "*wvzxn*yourflyouts*" -Directory | `
        Sort-Object Datum | Select-Object -First 1).FullName

    foreach ($plugin in (Get-ChildItem (Join-Path $dir "Plugins\*\*")))
    {
        $pluginVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($plugin.FullName).FileVersion
        $pluginBit = $plugin.FullName -replace "^.+\\(.+?)\\.+?`$","`$1"
        $newPath = Join-Path $env:USERPROFILE `
            "Documents\Rainmeter\Skins\@Vault\Plugins\$($plugin.BaseName)\$pluginVersion\$pluginBit"
        New-Item $newPath -ItemType Directory -Force
        Copy-Item $plugin -Destination $newPath -Force
        if ($pluginBit -match "64bit")
        {
            New-Item (Join-Path $env:APPDATA "Rainmeter\Plugins") -ItemType Directory -Force
            Copy-Item $plugin -Destination (Join-Path $env:APPDATA "Rainmeter\Plugins") -Force
        }
    }
    Remove-Item (Join-Path $dir "Plugins") -Recurse -Force
    Move-Item $dir -Destination (Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins\YourFlyouts") -Force
}

function YFSetWin11
{
    param
    (
        [string]$Path
    )

    $Vars = Join-Path $Path "@Resources\Vars.inc"
    $Win11 = Join-Path $Path "Main\Vars\Win11.inc"

    #   General Layout
    EditIniValues $Vars (
    "Media","0",
    "Ani","1",
    "AniDir","Bottom",
    "AniSteps","18",
    "Easetype","InOutCubic",
    "AnimationDisplacement","3",
    "Position","BC",
    "XPad","0",
    "YPad","44",
    "MediaType","Modern",
    "FetchImage","0",
    "Layout","Win11")

    #   Win11 Layout
    EditIniValues $Win11 (
    "PrimaryOpacity","253",
    "Width","246",
    "Scale","1.05",
    "Blur","None",
    "BlurCorner","Round",
    "Border","1")
}

function YFSetWin11Colors
{
    param
    (
        [string]$Path,
        [bool]$Dark
    )

    $Win11 = Join-Path $Path "Main\Vars\Win11.inc"

    #   Win11 Skin appearance
    $Primary = if ($Dark) { "40,35,42" } else { "230,225,235" }
    $Font = if ($Dark) { "255,255,255" } else { "0,0,0" }
    $Font2 = if ($Dark) { "125,125,125" } else { "150,150,150" }
    EditIniValues $Win11 (
        "PrimaryColor","$Primary",
        "FontColor","$Font",
        "FontColor2","$Font2")
}



#   Rainmeter check
$RMPath = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Rainmeter" -ErrorAction SilentlyContinue)."(default)"
if ( !$RMPath ) { $RMPath = Join-Path $env:PROGRAMFILES "Rainmeter" }
if ( !(Test-Path (Join-Path $RMPath "Rainmeter.exe")) )
{
    if (CheckInternetConnection) { ImportFuncs } else { return }
    $result = msgBox "(AutoDarkMode #script) YourFlyouts2 Script" "Rainmeter not found. Download and install now?"
    if ( $result ) { RMInstaller } else { return }
}

#   Start Rainmeter.exe
if ( !(Get-Process "rainmeter" -ErrorAction SilentlyContinue) )
{
    Start-Process (Join-Path $RMPath "Rainmeter.exe")
    Start-Sleep 1
}


#   YourFlyouts2 check
$YFPath = Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins\YourFlyouts"
if ( !(Test-Path $YFPath) )
{
    if (CheckInternetConnection) { ImportFuncs } else { return }
    $result = msgBox "(AutoDarkMode #script) YourFlyouts2 Script" "YourFlyouts2 not found. Download and install now?"
    if ($result) { yourFlyoutsInstaller; YFSetWin11 $YFPath } else { return }
}

#   YourFlyouts2 Win11 Skin setup (Light/Dark)
YFSetWin11Colors $YFPath $Dark
Start-Process (Join-Path $RMPath "Rainmeter.exe") "!RefreshApp"
Start-Sleep -Milliseconds 500
Start-Process (Join-Path $RMPath "Rainmeter.exe") "!ActivateConfig", "YourFlyouts\Main"