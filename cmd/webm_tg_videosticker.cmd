::  Convert video to Telegram video sticker (CMD)
::  
::  [Author]
::    boredwz | https://github.com/boredwz
::  
::  [Usage]
::    (!) !@`^&*[] - forbidden file/folder name symbols.
::    (!) FFmpeg.exe and FFprobe.exe must be in the PATH.
::    1. Drag and drop files onto this batch file.
::    2. Customize:
::      - Set output directory name 
::      - Set kb size

@echo off
if "%~1"=="" (echo Please drag and drop files onto this batch file.& pause & exit /b)
for /f "usebackq delims=" %%A in (` findstr /b /c:"::  " "%~f0" `) do echo %%A
setlocal EnableDelayedExpansion
echo:

call:CheckFFmpeg
call:Customize
echo:

set "savedLocation=%cd%"
cd /d "%~dp0"
set "pwsh=-nol -noni -nop -ep bypass"
set "scriptCmnd=& $([scriptblock]::Create((iwr -useb https://raw.githubusercontent.com/boredwz/win_scripts/master/ps/webm_tg_videosticker.ps1)))"
rem set "scriptCmnd=& $([scriptblock]::Create((gc -raw '.\ps\_ _.ps1')))"
set "scriptPath=..\ps\webm_tg_videosticker.ps1"

set count=0
set files=0
for %%F in (%*) do set /a files+=1
echo [!Time:~0,-3!] :::: Process start ::::
echo:
for %%I in (%*) do (
    set /a count+=1
    echo [!Time:~0,-3!] :: File [!count!/!files!] "%%~nxI"
    set "file=%%~dpI%outDir%%%~nI_tg.webm"
    if exist "%scriptPath%" (
        powershell %pwsh% -f "%scriptPath%" "%%~I" "!file!" "%kb%"
    ) else (
        powershell %pwsh% -c "%scriptCmnd% '%%~I' '!file!' '%kb%'"
    )
    if exist "!file!" (echo [!Time:~0,-3!] :: Done) else (echo [!Time:~0,-3!] :: ?)
    echo:
)

echo [!Time:~0,-3!] :::: Process end ::::

cd /d "%savedLocation%"
pause
exit /b





:CheckFFmpeg
where ffmpeg >nul 2>&1
set "checkFFmpeg=%errorlevel%"& ver >nul
if %checkFFmpeg% NEQ 0 (echo FFmpeg is not in the PATH. & pause & exit)
where ffprobe >nul 2>&1
set "checkFFprobe=%errorlevel%"& ver >nul
if %checkFFprobe% NEQ 0 (echo FFprobe is not in the PATH. & pause & exit)
exit /b

:Customize
set "kb=0"
set /p "customize=Customize options? [y/n]: "
if /I not "%customize%"=="y" (exit /b)
call:outDir
call:kb
exit /b

:outDir
set /p "customDir=Output directory name: "
if "%customDir%"=="" (exit /b)
rem check for !@`%^&*[]
echo %customDir% | findstr /r /c:"[!@`^&*\[\]]" >nul 2>&1
set "checkDir=%errorlevel%"& ver >nul
if %checkDir% NEQ 0 (set "outDir=%customDir%\") else (echo outDir contains forbidden symbols)
exit /b

:kb
set /p "kbcustom=kb (100-2097): "
if "%kbcustom%"=="" (exit /b)
:: check for 1000-2999
echo '%kbcustom%' | findstr /r /c:"^'[1-2][0-9][0-9][0-9]'" >nul 2>&1
set "check4=%errorlevel%"& ver >nul
:: check for 100-999
echo '%kbcustom%' | findstr /r /c:"^'[1-9][0-9][0-9]'" >nul 2>&1
set "check3=%errorlevel%"& ver >nul
if %check3% EQU 0 (set "kb=%kbcustom%")
if %check4% EQU 0 (if %kbcustom% LEQ 2097 (set "kb=%kbcustom%"))
exit /b