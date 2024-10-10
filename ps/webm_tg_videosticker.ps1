#  Convert video to Telegram video sticker (PowerShell)
#  
#  [Author]
#    boredwz | https://github.com/boredwz
#  
#  [Credits]
#    ffmpeg  | https://www.ffmpeg.org
#  
#  [Description]
#    Convert video to Telegram videosticker webm using FFmpeg.
#    (!) FFmpeg.exe and FFprobe.exe must be in the PATH.
#    (i) Recommended duration: <10 sec.
#     - Codec: VP9
#     - Max height and width: 512 px
#     - Max file size: 256 KB
#     - Bitrate: auto (max possible)
#     - No audio
#     - Metadata removed
#    
#    If the file >256KB after 1-st conversion, the script will try to convert again, but with a lower bitrate.
#    In most cases, this works, so I recommend using the <kb> parameter only if you still end up with a file >256KB (see warning info).
#    - Acceptable <kb> value range: 100-2097
#    - Recommended <kb> value range: 2000-2070
#    Some tests with <kb> value (after 1-st conversion):
#    - 2097: 14/25 files >256 KB
#    - 2060: 2/25 files >256 KB (default)
#    - 2000: 0/25 files >256 KB
#  
#  [Usage]
#    & ".\webm_tg_videosticker.ps1" ".\sticker.mp4"
#    & ".\webm_tg_videosticker.ps1" "C:\Users\USER\sticker.mp4" "some.webm"
#    & ".\webm_tg_videosticker.ps1" "C:\Users\USER\sticker.mp4" "some.webm" -kb 2075

param(
    [Alias("in", "file")]$inputFile,
    [Alias("out")]$outputFile,
    [Alias("kb")]$customKb
)




function New-WebmSticker() {
    param (
        [Parameter(Mandatory=$true)][Alias("file","path","f")]$InputFile,
        [Parameter(Mandatory=$true)][Alias("out","outfile")]$OutputFile,
        [Parameter(Mandatory=$true)][Alias("kb")]$Kbps
    )

    ffmpeg.exe @(
        "-i", $InputFile,
        "-loglevel", "fatal",
        "-vf", "`"scale='if(gt(iw,ih),512,-1)':'if(gt(ih,iw),512,-1)'`"",
        "-c:v", "libvpx-vp9",
        "-b:v", "$($Kbps)k",
        "-an",
        "-y",
        "-pass", "1",
        "-threads", ((Get-WmiObject Win32_Processor).NumberOfLogicalProcessors),
        "-f", "webm", #                                                             file format: webm
        "NUL" #                                                                     disable output file
    )
    ffmpeg.exe @(
        "-i", $InputFile,
        "-loglevel", "fatal",
        "-map_metadata", "-1", #                                                    remove metadata
        "-fflags", "+bitexact", "-flags:v", "+bitexact", #                          remove lib version data
        "-vf", "`"scale='if(gt(iw,ih),512,-1)':'if(gt(ih,iw),512,-1)'`"", #         resize max 512px height or width
        "-c:v", "libvpx-vp9", #                                                     video codec: vp9
        "-b:v", "$($Kbps)k", #                                                      bitrate
        "-an", #                                                                    remove audio
        "-y",
        "-pass", "2",
        "-threads", ((Get-WmiObject Win32_Processor).NumberOfLogicalProcessors), #  get CPU threads
        $OutputFile
    )

    return @{
        Exists = Test-Path $OutputFile -PathType Leaf -ErrorAction 0;
        Size = (Get-Item -Path $OutputFile -ErrorAction 0).Length / 1KB;
    }
}

function Get-VideoBitrate($Path, [switch]$Kbps) {
    if ( !(Test-Path $Path -PathType Leaf -ErrorAction 0) ) {return}
    $b = (ffprobe.exe @(
        "-v", "fatal",
        "-select_streams", "v:0",
        "-show_entries", "stream=bit_rate"
        "-of", "default=noprint_wrappers=1"
        $Path
    )) -replace '^bit_rate=(\d+)$','$1'
    if ($Kbps) {return [Math]::Round(($b / 1000), 3)}
    return $b
}

function Get-VideoDuration {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Alias("f")][switch]$Full,
        [Alias("s")][switch]$Seconds
    )
    if ( !(Test-Path $Path -PathType Leaf -ErrorAction 0) ) {return}
    $d = ffprobe.exe @(
        "-v", "fatal",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1",
        "-sexagesimal",
        $Path
    )
    $r = '^(\d+?)\:(\d\d)\:(\d\d)(?:\.(\d+))?'
    $f = @{
        Hours=[Math]::Round(($d -replace $r,'$1'));
        Minutes=[Math]::Round(($d -replace $r,'$2'));
        Seconds=[Math]::Round(($d -replace $r,'$3'));
        Milliseconds=($d -replace $r,'$4');
    }
    if ($Full) {return $f}
    if ($Seconds) {return [Math]::Round(("{0}.{1}" -f $f.Seconds, $f.Milliseconds), 3)}
    return $d
}

function Test-VideoFile($Path) {
    if ( !(Test-Path $Path -PathType Leaf -ErrorAction 0) ) {return}
    $v = ffprobe.exe @(
        "-v", "fatal",
        "-select_streams", "v:0",
        "-show_entries", "stream=codec_type",
        "-of", "default=noprint_wrappers=1:nokey=1",
        $Path
    )
    return ($v -eq "video")
}




$e = "webm_tg_videosticker.ps1"

# init check
if ( !(Get-Command ffmpeg -ErrorAction 0) ) {return "[$e] FFmpeg is not in the PATH."}
if ( !(Get-Command ffprobe -ErrorAction 0) ) {return "[$e] FFprobe is not in the PATH."}
if ([string]::IsNullOrEmpty($inputFile)) {return "[$e] Input file is null or empty."}
if ( !(Test-Path $inputFile -PathType Leaf) ) {return "[$e] '$inputFile' not found."}
if ( !(Test-VideoFile $inputFile) ) {return "[$e] '$inputFile' is not a video."}

# save current PS location
$savedLocation = Get-Location

# set location to input file dir
$inputFile = ((Resolve-Path $inputFile).Path).ToString()
Set-Location (Split-Path $inputFile -Parent)

# get input file name without extension
$name = $inputFile -replace '^(.*\\)([^\\]+)(\.[^\\]+?)$','$2'
$tempFile = "$($name)_temp.webm"

# set output file
$outputFile = `
    if ($outputFile) {
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($outputFile)
    } else {"$($name)_tg.webm"}

# get target bitrate
$kb = 2060 #    default: 2097.152
if ($customKb -match '^([1-9][0-9]{2}|1[0-9]{3}|20[0-9][0-7])$') {$kb = $customKb}
$videoDuration = Get-VideoDuration $inputFile -Seconds
$targetBitrate = if ($videoDuration) {
    $kb / (Get-VideoDuration $inputFile -Seconds)
} else {
    "250"
}
$inputFileBitrate = Get-VideoBitrate $inputFile -Kbps
if ($inputFileBitrate -lt $targetBitrate) {$targetBitrate = $inputFileBitrate}
if ($targetBitrate -gt 750) {$targetBitrate = 750}
$targetBitrate = [Math]::Floor($targetBitrate)
"[$e] Duration: ~{0:N1}s | Target bitrate: ~{1}kbit" -f $videoDuration, $targetBitrate



# ffmpeg convert
"[$e] FFmpeg converting (two pass)..."
$webm = New-WebmSticker $inputFile $tempFile $targetBitrate

# try re-convert with lower bitrate (92-98% of the target bitrate)
if (($webm.Exists) -and ($webm.Size -gt 256)) {
    $perc = (256 / $webm.Size) - 0.01
    $newBitrate = [Math]::Floor($targetBitrate * $perc)
    "[$e] Size: ~{0:N1}KB, re-converting with ~{1}kbit..." -f ($webm.Size), $newBitrate
    $webm = New-WebmSticker $inputFile $tempFile $newBitrate
}

if ( !($webm.Exists) ) {
    Write-Host "[$e] " -NoNewline
    Write-Host "FFmpeg converting error" -ForegroundColor Red
    return
}
if ($webm.Size -gt 256) {
    Write-Host "[$e] " -NoNewline
    Write-Host "File size still exceeds 256 KB" -ForegroundColor Yellow
}



# create dir
$outDir = Split-Path $outputFile -Parent
if ( !(Test-Path $outDir -PathType Container -ErrorAction 0) ) {$null = mkdir $outDir}

# invoke webm_distortduration.ps1
#"[$e] invoking webm_distortduration.ps1..."
$distortFile = Get-ChildItem (Split-Path -Parent $savedLocation) -File `
    -Recurse -Depth 1 `
    -Filter "webm_distortduration.ps1" `
    -ErrorAction 0 `
    | Select-Object -First 1
if ($distortFile) {
    & ($distortFile.FullName) $tempFile $outputFile
} else {
    $distort = Invoke-WebRequest -useb `
        "https://raw.githubusercontent.com/boredwz/win_scripts/master/ps/webm_distortduration.ps1"
    & $([scriptblock]::Create(($distort))) $tempFile $outputFile
}

If (Test-Path $outputFile -PathType Leaf -ErrorAction 0) {
    $fileSize = (Get-Item -Path $outputFile).Length / 1KB
    Write-Host "[$e] " -NoNewline
    if ($fileSize -gt 256) {
        Write-Host "Issue (> 256 KB)" -ForegroundColor Yellow -NoNewline
    } else {
        Write-Host "Success" -ForegroundColor Green -NoNewline
    }
    Write-Host (", file size: ~{0:N1}KB" -f $fileSize)
} else {
    Write-Host "[$e] " -NoNewline
    Write-Host "Failed =(" -ForegroundColor Red
}

# clean up
Remove-Item $tempFile -ErrorAction 0
Remove-Item "ffmpeg2pass*.log" -ErrorAction 0

# restore PS location
Set-Location $savedLocation