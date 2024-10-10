param(
    $Path,
    [Alias("upgrade")][switch]$Update,
    [Alias("uninst","del","remove")][switch]$Uninstall
)

function Echoo($text) {
    Write-Host "> $text"-ForegroundColor 3
}

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





$savedLocation = Get-Location
if (!$Path) {$Path = $env:USERPROFILE}
if ( !(Test-Path $Path -PathType Container -ErrorAction 0) ) {$Path = $env:USERPROFILE}
Set-Location $Path

$dir = "win_scripts"
$backup = "_win_scipts_bc"

if ($Uninstall) {
    Echoo "Uninstalling..."
    $a = "AutoDarkMode"
    if($null = Get-Process "$($a)Svc" -ErrorAction 0){
        $aw = $true;
        $null = & "$env:LOCALAPPDATA\Programs\$a\adm-app\$($a)Shell.exe" --exit
        Start-Sleep 2
    }
    $dir, "$env:APPDATA\AutoDarkMode\scripts.yaml" | Remove-Item -Recurse -Force -ErrorAction 0
    if($aw) {Start-Process "$env:LOCALAPPDATA\Programs\$a\adm-app\$($a)Svc.exe"}
    Echoo "Done"
    return
}

""
Echoo "Creating backup..."
Copy-Item "$dir\" "$backup\" -Force -Recurse -ErrorAction 0

Echoo "Removing old version and junk files..."
Get-ChildItem -Directory | `
    Where-Object {($_.name -eq $dir) -or ($_.name -eq "$dir-master")} | `
    Remove-Item -Recurse -Force
Get-ChildItem -File | `
    Where-Object {$_.name -eq "m.zip"} | `
    Remove-Item -Recurse -Force

Echoo "Downloading and installing win_scripts..."
Invoke-WebRequest https://github.com/boredwz/win_scripts/archive/refs/heads/master.zip -OutFile m.zip
Expand-Archive m.zip -DestinationPath ".\"
Remove-Item m.zip
Rename-Item "$dir-master" -NewName $dir

if (!$Update) {
    Echoo "Setting up ADM scripts.yaml..."
    $c = (Get-Content "$dir\ps\adm_scripts.yaml") -replace `
        'C:\\\\\.\.CHANGE THIS\.\.\\\\win_scripts\\\\ps',
        ((Join-Path $Path "win_scripts\ps") -replace '\\','\\')
    $c -replace 'Enabled: false','Enabled: true' | Set-Content "$env:APPDATA\AutoDarkMode\scripts.yaml" -Force
}

Echoo "Restoring backup..."
if (Test-Path $backup -PathType Container) {
    Copy-Folder -source "$backup\" -destination "$dir\"
    Remove-Item "$backup\" -Recurse -Force
}
Echoo "Done"
""

Set-Location $savedLocation