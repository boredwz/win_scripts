#  YourFlyouts2 (Win11 Skin) (PowerShell)
#  
#  [Author]
#    boredwz | https://github.com/boredwz
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
#    & ".\YF2_W11.ps1"; & ".\YF2_W11.ps1" -Dark

#Requires -Version 5

param
(
    [switch]$Dark,
    [switch]$Light
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
    $gistScriptUrl = "https://gist.githubusercontent.com/boredwz/e7872773f4c44671ca37fad7ca3912b7/raw/Get-GithubLatestReleaseUrl.ps1"
    Set-Location $env:TMP
    $rmUrl = (Invoke-Expression "&{$(Invoke-WebRequest -useb $gistScriptUrl)} rainmeter rainmeter").Files|Select-Object -f 1
    $ProgressPreference = 0
    iwr $rmUrl -OutFile ".\rm.exe"
    $ProgressPreference = 2
    
    #   Install
    Start-Process ".\rm.exe" "/S" -Wait
    Remove-Item ".\rm.exe" -Force

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
    $gistScriptUrl = "https://gist.githubusercontent.com/boredwz/e7872773f4c44671ca37fad7ca3912b7/raw/Get-GithubLatestReleaseUrl.ps1"
    Set-Location $env:TMP
    $zipUrl = (Invoke-Expression "&{$(Invoke-WebRequest -useb $gistScriptUrl)} boredwz YourFlyouts").Zip
    $ProgressPreference = 0
    Invoke-WebRequest $zipUrl -OutFile "yf2.zip"
    $ProgressPreference = 2

    #   Manual Install
    $null = Expand-Archive "yf2.zip"
    Remove-Item "yf2.zip" -Force
    $dir = (Get-ChildItem ".\yf2\*boredwz*yourflyouts*" -Directory|Select-Object -First 1).FullName

    foreach ($plugin in (Get-ChildItem (Join-Path $dir "Plugins\*\*")))
    {
        $pluginVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($plugin.FullName).FileVersion
        $pluginBit = $plugin.FullName -replace "^.+\\(.+?)\\.+?`$","`$1"
        $newPath = Join-Path $env:USERPROFILE `
            "Documents\Rainmeter\Skins\@Vault\Plugins\$($plugin.BaseName)\$pluginVersion\$pluginBit"
        $null = New-Item $newPath -ItemType Directory -Force
        $null = Copy-Item $plugin -Destination $newPath -Force
        if ($pluginBit -match "64bit")
        {
            $null = New-Item (Join-Path $env:APPDATA "Rainmeter\Plugins") -ItemType Directory -Force
            $null = Copy-Item $plugin -Destination (Join-Path $env:APPDATA "Rainmeter\Plugins") -Force
        }
    }
    Remove-Item (Join-Path $dir "Plugins") -Recurse -Force
    $null = Move-Item $dir -Destination (Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins\YourFlyouts") -Force

    Get-ChildItem $env:TMP -Directory|?{$_.name -eq "yf2"}|Remove-Item -Force
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
Set-Location $RMPath
if ( !(Test-Path (".\Rainmeter.exe")) )
{
    if (!(Test-Connection "www.google.com" -Count 2 -Quiet)) {return}
    $result = msgBox "(AutoDarkMode #script) YourFlyouts2 Script" "Rainmeter not found. Download and install now?"
    if ($result) {RMInstaller} else {return}
}

#   Start Rainmeter.exe
if ( !(Get-Process "rainmeter" -ErrorAction SilentlyContinue) )
{
    Start-Process ".\Rainmeter.exe" -WorkingDirectory $RMPath
    Start-Sleep 1
}


#   YourFlyouts2 check
$YFPath = Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins\YourFlyouts"
if ( !(Test-Path $YFPath) )
{
    if (!(Test-Connection "www.google.com" -Count 2 -Quiet)) {return}
    $result = msgBox "(AutoDarkMode #script) YourFlyouts2 Script" "YourFlyouts2 not found. Download and install now?"
    if ($result) {YFInstaller; YFSetWin11 $YFPath} else {return}
}

#   YourFlyouts2 Win11 Skin setup (Light/Dark)
YFSetWin11Colors $YFPath $Dark
Set-Location $RMPath
Start-Process ".\Rainmeter.exe" "!RefreshApp"
Start-Sleep -Milliseconds 500
Start-Process ".\Rainmeter.exe" "!ActivateConfig", "YourFlyouts\Main"

if ($result) {
    msgBox "(AutoDarkMode #script) YourFlyouts2 Script" "Successfully installed!"
}

return