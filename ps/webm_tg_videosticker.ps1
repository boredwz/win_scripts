#  Convert video to Telegram video sticker (PowerShell)
#  
#  [Author]
#    boredwz | https://github.com/boredwz
#  
#  [Credits]
#    ffmpeg  | https://www.ffmpeg.org
#  
#  [Description]
#    (!) FFmpeg.exe and FFprobe.exe must be in the PATH.
#    Using ffmpeg convert video to Telegram webm. Recommended duration: 4-8 sec.
#     - Codec: VP9
#     - Max height and width: 512 px
#     - Max file size: 256 KB
#     - Bitrate: auto (max possible)
#     - No audio
#     - Metadata removed
#    
#    About custom kb: https://trac.ffmpeg.org/wiki/Encode/H.264#twopass
#  
#  [Usage]
#    & ".\webm_tg_videosticker.ps1" ".\sticker.mp4"
#    & ".\webm_tg_videosticker.ps1" "C:\Users\USER\sticker.mp4" "some.webm"

param(
    [Alias("in", "file")]$inputFile,
    [Alias("out")]$outputFile,
    [Alias("kb")]$customKb
)

function Get-VideoDuration($path) {
    $a = @(
        "-v", "error",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1",
        "-sexagesimal",
        $path
    )
    return $(try {ffprobe $a} catch {})
}

$e = "webm_tg_videosticker.ps1"

# init check
if ( !(Get-Command ffmpeg -ErrorAction 0) ) {return "[$e]: FFmpeg is not in the PATH."}
if ( !(Get-Command ffprobe -ErrorAction 0) ) {return "[$e]: FFprobe is not in the PATH."}
if ([string]::IsNullOrEmpty($inputFile)) {return "[$e]: Input file is null or empty."}
if ( !(Test-Path $inputFile -PathType Leaf) ) {return "[$e]: '$inputFile' not found."}



# save current PS location
$savedLocation = Get-Location

# set location to input file dir
$inputFile = ((Resolve-Path $inputFile).Path).ToString()
Set-Location (Split-Path $inputFile -Parent)

# get input file name without extension
$name = $inputFile -replace '^(.*\\)([^\\]+)(\.[^\\]+?)$','$2'

# set output file
$outputFile = `
    if ($outputFile) {
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($outputFile)
    } else {"$($name)_tg.webm"}

# get target bitrate
$kb = 2000 #    default: 2097.152
if ($customKb -match '^([1-9][0-9]{2}|1[0-9]{3}|20[0-9][0-7])$') {$kb = $customKb}
$videoDuration = (Get-VideoDuration $inputFile) -replace '^.+?(1?\d\.\d).*?$','$1' # Seconds(0-19).Milliseconds(0-9)
$targetBitrate = if ($videoDuration) {
    "{0}k" -f (($kb / $videoDuration) -replace '\..+','')
} else {
    "500k"
}

"[$e]: duration = $($videoDuration)s | target bitrate = $($targetBitrate)bit"


# ffmpeg convert (two-pass)
"[$e]: ffmpeg converting..."
ffmpeg @(
    "-i", $inputFile,
    "-loglevel", "fatal",
    "-vf", "`"scale='if(gt(iw,ih),512,-1)':'if(gt(ih,iw),512,-1)'`"",
    "-c:v", "libvpx-vp9",
    "-b:v", $targetBitrate,
    "-an",
    "-pass", "1",
    "-f", "null", "out.null"
)
ffmpeg @(
    "-i", $inputFile,
    "-loglevel", "fatal",
    "-map_metadata", "-1", "-fflags", "+bitexact", "-flags:v", "+bitexact", #   remove metadata
    "-vf", "`"scale='if(gt(iw,ih),512,-1)':'if(gt(ih,iw),512,-1)'`"",
    "-c:v", "libvpx-vp9",
    "-b:v", $targetBitrate,
    "-an",
    "-pass", "2",
    "$($name)_temp.webm"
)


# create dir
$outDir = Split-Path $outputFile -Parent
if ( !(Test-Path $outDir -PathType Container -ErrorAction 0) ) {$null = mkdir $outDir}

# invoke webm_distortduration.ps1
#"[$e]: invoking webm_distortduration.ps1..."
$distortFile = Get-ChildItem (Split-Path -Parent $savedLocation) -File `
    -Recurse -Depth 1 `
    -Filter "webm_distortduration.ps1" `
    -ErrorAction 0 `
    | Select-Object -First 1
if ($distortFile) {
    & ($distortFile.FullName) "$($name)_temp.webm" $outputFile
} else {
    $distort = Invoke-WebRequest `
        -useb https://raw.githubusercontent.com/boredwz/win_scripts/master/ps/webm_distortduration.ps1
    Invoke-Expression "& $([scriptblock]::Create($distort)) '$($name)_temp.webm' '$outputFile'"
}

"[{0}]: {1} successfully created, file size: [~{2} KB]" -f `
    $e, `
    ($outputFile -replace '^.*\\(.*)$','$1'), `
    ((("{0:N1}" -f ((Get-Item -Path $outputFile).Length / 1KB))) -replace '^(\d+?)\.0$','$1')

# clean up
Remove-Item "$($name)_temp.webm" -ErrorAction 0
Remove-Item "ffmpeg2pass*.log" -ErrorAction 0

# restore PS location
Set-Location $savedLocation