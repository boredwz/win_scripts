# Telegram webm video sticker converter

Create Telegram video sticker files using FFmpeg.

## Video sticker requirements from official [Telegram FAQ](https://core.telegram.org/stickers/webm-vp9-encoding#video-requirements-for-stickers-and-emoji)

| Key | Value |
|---|---|
| Format | `.webm` |
| FPS | up to `30fps` |
| Codec | `vp9` |
| Audio | no audio |
| Dimensions | up to `512x512px` |
| Duration | up to `3sec`* |
| File size | up to `256KB` |

_\* can be bypassed_

## Usage

> [!WARNING]
> `FFmpeg.exe` and `FFprobe.exe` must be in the PATH.

<details>

**<summary>Automatic FFmpeg installation via PowerShell</summary>**

```powershell
$ProgressPreference=0;$g="https://gist.githubusercontent.com/boredwz/e7872773f4c44671ca37fad7ca3912b7/raw/Get-GithubLatestReleaseUrl.ps1"; $url=(iex "&{$(iwr -useb $g)} BtbN FFmpeg-Builds").Files|?{$_ -match "master-latest-win64-gpl\.zip"}|select -f 1; iwr $url -o f.zip;$ProgressPreference=2;Expand-Archive f.zip ".\"; ls -dir|?{$_.name -match "ffmpeg.+?win64"}|%{$a="$($_.name)\bin"; cp $_ -dest $env:USERPROFILE -for -r; ri $_ -rec -for}; $p=([System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)); $a="$env:USERPROFILE\$a"; if($p -notlike "*$a*"){[System.Environment]::SetEnvironmentVariable("Path", ("$($p -replace ';+$','');$a"), [System.EnvironmentVariableTarget]::User)}
```

- Install ffmpeg: `C:\Users\(User)\ffmpeg*`
- Add `ffmpeg.exe`, `ffprobe.exe` and `ffplay.exe` to the PATH.

</details>

<br>

&nbsp; 1\. **Setup**
- Clone the repo
  
  **OR**

- Download batch script via PowerShell:
  ```powershell
  iwr "https://raw.githubusercontent.com/boredwz/win_scripts/refs/heads/master/cmd/webm_tg_videosticker.cmd" -o ".\webm_tg_videosticker.cmd"
  ```

<br>

&nbsp; 2\. **Drag and drop files onto `webm_tg_videosticker.cmd` batch file**

> [!TIP]
> Create a shortcut of `webm_tg_videosticker.cmd` and work with it for ease of use.

<br>

## Customization

> [!NOTE]
> - You can use any video format that FFmpeg supports.  
> - Metadata will be removed.

> [!TIP]
> Recommendation (for the video to convert):  
> - Video duration — `<10` seconds.  
> - Color space — `YUV` (higher compression).

| Parameter | Value | Description |
|---|---|---|
| Output directory | `text` | *Create a folder and place all converted files there*<br><br><code>!@\`^&\*[]</code> — forbidden file/folder name symbols. |
| kb | `100-2097` | *It is a formula for calculating the estimated bitrate so that the file size does not exceed 256KB, based on https://trac.ffmpeg.org/wiki/Encode/H.264#twopass*<br><br>`2000-2070` — recommended value range. |
    
If the file size is >256 KB after the first conversion, the script will try to convert it again, but with a lower bitrate. In most cases, this works, so I recommend using `kb` parameter only if you still get a file >256KB (see warning info).

<br>

## Example — test various `kb` values

Input: 25 different video files (MOV, MP4, WEBM) with a duration of 8-13 seconds.

Results of the first conversion:

| kb value | result (>256KB) |
|---|---|
| `2097` | 14/25 |
| `2060` <sup>(default)</sup> | 2/25 |
| `2000` | 1/25 |

After the second conversion, all files were less than 256KB. But this means more time spent per video, so the optimal solution is **\~2060**.

<br>