#  YourFlyouts2 (Win11 Skin) (PowerShell)
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

function Get-GithubLatestReleaseUrl
{
    param
    (
        [string]$Author,
        [string]$Repo,
        [string]$Pattern
    )

    $LatestReleases = Invoke-WebRequest "https://api.github.com/repos/$Author/$Repo/releases/latest" | ConvertFrom-Json
    return ($LatestReleases.assets.browser_download_url | Select-String $Pattern).Line
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
        if ($a -eq "") {$a = "[^;].*?"}
        $text = $text -replace "^($a\=).*`$","`${1}$b"
    }
    $text | Set-Content $Path
}

function RMInstaller
{
    $exePath = "$env:PROGRAMFILES\Rainmeter\Rainmeter.exe"

    #   Download
    $installerUrl = Get-GithubLatestReleaseUrl 'rainmeter' 'rainmeter' '.exe'
    $fileName = $installerUrl -replace '^.+\/([^\/]+?)$','$1'
    (New-Object System.Net.WebClient).DownloadFile($installerUrl, "$env:TMP\$fileName")
    
    #   Install
    Start-Process "$env:TMP\$fileName" -Wait -ArgumentList "/S"
    Remove-Item "$env:TMP\$fileName" -Force
    Start-Sleep 1

    #   Start Rainmeter.exe
    if ( !(Get-Process 'rainmeter' -ErrorAction SilentlyContinue) ) { Start-Process $exePath; Start-Sleep 2 }

    #   Rainmeter Cleanup
    "Clock", "Disk", "System", "Welcome" | ForEach-Object { . $exePath !DeactivateConfig "illustro\$_" }
    . $exePath "!Quit"
    Start-Sleep 1
    $ini="$env:APPDATA\Rainmeter\Rainmeter.ini"
    (Get-Content $ini) -replace '(SkinPath=.+?)$',"`$1`nHardwareAcceleration=1`nDisableAutoUpdate=1`nDisableVersionCheck=1" | Set-Content $ini
    Start-Process $exePath
}

function YFInstaller
{
    Set-Location "$env:TMP"

    #   Download
    $installerUrl = Get-GithubLatestReleaseUrl 'Jax-Core' 'YourFlyouts' '.rmskin'
    $name = $installerUrl -replace '^.+\/([^\/]+)\.[^\.]+?$','$1'
    (New-Object System.Net.WebClient).DownloadFile($installerUrl, "$env:TMP\$name.zip")

    #   Manual Install
    Expand-Archive ".\$name.zip"
    Remove-Item ".\$name.zip" -Force
    Copy-Item ".\$name\Skins\YourFlyouts" -Destination "$env:USERPROFILE\Documents\Rainmeter\Skins\YourFlyouts" -Recurse -Force
    foreach ($plugin in (Get-ChildItem ".\$name\Plugins\*\*"))
    {
        $pluginVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($plugin.FullName).FileVersion
        $pluginBit = $plugin.FullName -replace '^.+\\(.+?)\\.+?$','$1'
        $newPath = "$env:USERPROFILE\Documents\Rainmeter\Skins\@Vault\Plugins\$($plugin.BaseName)\$pluginVersion\$pluginBit"
        New-Item $newPath -ItemType Directory -Force
        Copy-Item $plugin -Destination $newPath -Force
        if ($pluginBit -eq "64bit")
        {
            New-Item "$env:APPDATA\Rainmeter\Plugins" -ItemType Directory -Force
            Copy-Item $plugin -Destination "$env:APPDATA\Rainmeter\Plugins" -Force
        }
    }
    Remove-Item ".\$name" -Recurse -Force
}

function YFSetWin11
{
    param
    (
        [string]$Path
    )

    $Vars = "$Path\@Resources\Vars.inc"
    $Win11 = "$Path\Main\Vars\Win11.inc"

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

    $Win11 = "$Path\Main\Vars\Win11.inc"

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
if ( !$RMPath ) { $RMPath = "$env:PROGRAMFILES\Rainmeter" }
if ( !(Test-Path "$RMPath\Rainmeter.exe") )
{
    $result = msgBox "(AutoDarkMode #script) YourFlyouts2 Script" "Rainmeter not found. Download and install now?"
    if ( $result ) { RMInstaller } else { return }
}

#   Start Rainmeter.exe
if ( !(Get-Process "rainmeter" -ErrorAction SilentlyContinue) ) { Start-Process "$RMPath\Rainmeter.exe"; Start-Sleep 1 }

#   YourFlyouts2 check
$YFPath = "$env:USERPROFILE\Documents\Rainmeter\Skins\YourFlyouts"
if ( !(Test-Path $YFPath) )
{
    $result = msgBox "(AutoDarkMode #script) YourFlyouts2 Script" "YourFlyouts2 not found. Download and install now?"
    if ($result) { yourFlyoutsInstaller; YFSetWin11 $YFPath } else { return }
}

#   YourFlyouts2 Win11 Skin setup (Light/Dark)
YFSetWin11Colors $YFPath $Dark
. "$RMPath\Rainmeter.exe" !RefreshApp
Start-Sleep -Milliseconds 500
. "$RMPath\Rainmeter.exe" !ActivateConfig "YourFlyouts\Main"