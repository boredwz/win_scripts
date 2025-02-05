param(
    $Destination,
    [Alias("upgrade")][switch]$Update,
    [Alias("uninst","del","remove")][switch]$Uninstall,
    [Alias("vb")][switch]$Vbs
)

function Echoo($text,[int]$lvl=0) {Write-Host "$([string]::new(' ',$lvl))> $text"-f 3}

function Copy-Folder($source, $destination) {
    # Get all files from the source folder
    $files = Get-ChildItem -Path $source -Recurse
    
    foreach ($file in $files) {
        # Construct the destination path
        $destPath = $file.FullName.Replace($source, $destination)
        
        # Check if the file already exists at the destination
        if (-not (Test-Path -Path $destPath)) {
            # Create the directory if it doesn't exist
            $destDir = [System.IO.Path]::GetDirectoryName($destPath)
            if (-not (Test-Path -Path $destDir)) {
                $null = New-Item -ItemType Directory -Path $destDir
            }
            # Copy the file
            Copy-Item -Path $file.FullName -Destination $destPath
        }
    }
}



$masterzipUrl = "https://github.com/boredwz/win_scripts/archive/refs/heads/master.zip"
$admData = "$env:APPDATA\AutoDarkMode"
$admLocation = "$env:LOCALAPPDATA\Programs\AutoDarkMode\adm-app"
$admShellPath = "$admLocation\AutoDarkModeShell.exe"
$admSvcPath = "$admLocation\AutoDarkModeSvc.exe"
$customLocation = $env:LOCALAPPDATA
if ($Destination) {if (Test-Path $Destination -Type Container) {$customLocation = $Destination}}
$winscriptsPath = "$customLocation\win_scripts"
$winscriptsBackupName = "win_scipts_$(Get-Date -uformat '%Y-%m-%d_%H-%M-%S')"

" "
Echoo "[adm_helper_installer]"
Echoo "Location: `"$winscriptsPath`""
" "

# Uninstall win_scripts and exit.
if ($Uninstall) {
    Echoo "Uninstalling..."
    
    Echoo "Quitting ADM..." 1
    if($null = Get-Process "AutoDarkModeSvc" -ea 0){
        $null = & $admShellPath --exit
        $admToStart = $true;
        Start-Sleep 2
    }

    Echoo "Creating backup of scripts.yaml..." 1
    If ((Get-Item "$admData\scripts.yaml").Length -ne 289) {
        Rename-Item "$admData\scripts.yaml" -NewName `
            "scripts_$(Get-Date -uformat '%Y-%m-%d_%H-%M-%S').BACKUP"
    }

    Echoo "Removing win_scripts dir..." 1
    $winscriptsPath | Remove-Item -Recurse -Force -ea 0
    
    Echoo "Starting ADM..." 1
    if($admToStart) {$null = & $admSvcPath}

    Echoo "Done";return
}

# Exit if ADM not found.
if (!(Test-Path $admLocation -Type Container) -or !(Test-Path $admData -Type Container)) {
    Echoo "Auto Dark Mode not found.";return
}



# 1. Create backup of custom scripts.
if (Test-Path $winscriptsPath -Type Container) {
    Echoo "Creating backup of custom scripts..."
    Rename-Item $winscriptsPath -NewName $winscriptsBackupName
    $winscriptsBackupCreated = $true
}

# 2. Download win_scripts.
Echoo "Downloading win_scripts..."
Invoke-WebRequest $masterzipUrl -OutFile "$customLocation\win_scripts-master.zip"
Expand-Archive "$customLocation\win_scripts-master.zip" -DestinationPath "$customLocation\"
Remove-Item "$customLocation\win_scripts-master.zip" -Force
Rename-Item "$customLocation\win_scripts-master" -NewName "win_scripts"

# 3. Modify scripts.yaml (Do not if [-Update]).
if (!$Update) {
    Echoo "Modifying scripts.yaml..."
    $folder = if ($Vbs) {"vbs"} else {"ps"}
    $find = 'C:\\\\\.\.CHANGE THIS\.\.\\\\win_scripts\\\\' + $folder
    $replace = ((Join-Path $customLocation "win_scripts\$folder") -replace '\\','\\')
    $c = (Get-Content "$winscriptsPath\$folder\adm_scripts.yaml") -replace $find, $replace
    $c -replace 'Enabled: false','Enabled: true' | Set-Content "$admData\scripts.yaml" -Force
}

# 4. Restore backup of custom scripts.
if ($winscriptsBackupCreated) {
    Echoo "Restoring custom scripts..."
    Copy-Folder -source "$customLocation\$winscriptsBackupName\" -destination "$winscriptsPath\"
    Remove-Item "$customLocation\$winscriptsBackupName\" -Recurse -Force
}

Echoo "Done";" ";return