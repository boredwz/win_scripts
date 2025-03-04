'  adm_helper (VBScript)
'  
'  [Author]
'    boredwz | https://github.com/boredwz/win_scripts
'  
'  [Info]
'    - Prevent ADM script multiple instance (lock file)
'    - Restart explorer.exe and restore tabs
'    - Launch external scripts
'    - Refresh ADM theme to fix wallpaper not changing error (force theme toggle)
'    - Restore last active window
'  
'  [Usage]
'    Command-line parameters:
'      [/theme:<light/dark>] — Set theme, if not specified then Windows Theme will be used
'      [/trigger:<adm trigger name>] — Set AutoDarkMode trigger
'      [/restartMode:<normal/minimized>] — Set explorer.exe restart mode
'      [/restart] — Force restart explorer.exe
'      [/noAdmRefresh] — Do not refresh ADM theme
'      [/noScripts] — Do not launch external scripts (ps\_adm_helper\*.ps1)
'      [/noActivate] — Do not restore last active window (ps\foreground_window.ps1)
'    
'    Examples:
'      cscript //nologo adm_helper.vbs /trigger:TimeSwitchModule /theme:Dark /restart
'      cscript //nologo adm_helper.vbs /theme:Light /trigger:BatteryStatusChanged /noScripts /noActivate
'      cscript //nologo adm_helper.vbs /restart /noAdmRefresh



Dim trigger, isThemeDark, strTheme, isRestartModeMinimized, doRestart, doRefreshAdm, doScripts, doActivateWin
Dim activeWinId, explorerRestarted, admRefreshed, psfwPath

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")
objShell.CurrentDirectory = objFSO.GetParentFolderName(WScript.ScriptFullName)
objShell.CurrentDirectory = objFSO.GetFolder("..").Path
admRefreshed = False
explorerRestarted = False

Call LockCheck("vbs\" & WScript.ScriptName & "_lockfile") ' Check Lock File
Call SetArguments() ' Set param, argument variables

' Echo start
Call Echoo("", False)
'Call EchoArguments()
Call Echoo("", False)
Call Echoo("[" & "==== " & WScript.ScriptName & " ====" & "]", True)
Call Echoo(" Theme: " & strTheme, True)
Call Echoo(" Trigger: " & trigger, True)
Call Echoo("", True)

Call RestartExplorer() ' Restart explorer.exe
'Call RunPsScripts() ' Run PS Theme scripts (ps\_adm_helper\*.ps1)
'Call RefreshAdmTheme() ' Refresh ADM theme if wallpaper not changing
Call RestoreActiveWindow() ' Save currently active window (ps\foreground_window.ps1)

Call LockDelete("vbs\" & WScript.ScriptName & "_lockfile") ' Delete Lock File

' Echo end
Call Echoo("[" & String(Len("==== " & WScript.ScriptName & " ===="), "=") & "]", True)
Call Echoo("", False)

Call WScript.Quit()





Sub LockDelete(lock)
    If (objFSO.FileExists(lock)) Then Call objFSO.DeleteFile(lock, True)
End Sub

' Lock file check: if exists, then exit; if not then create and set auto-delete script (30s)
Sub LockCheck(lock)
    If (objFSO.FileExists(lock)) Then Call MultiInstanceCase()
    On Error Resume Next
    Call objFSO.CreateTextFile(lock, False)
    If Err.Number <> 0 Then Call MultiInstanceCase()
    On Error Goto 0
    command = "sleep 30;'" & lock & "'|?{test-path $_ -type leaf}|ri -for"
    Call objShell.Run("powershell.exe -noni -nol -nop -ep bypass -c """ & command & """", 0, False)
End Sub

Sub MultiInstanceCase()
    Call Echoo("", False)
    Call Echoo("", False)
    Call Echoo("==== multi instance ====", False)
    Call Echoo("", False)
    Call WScript.Quit()
End Sub

' Set param, argument variables
Sub SetArguments()
    Dim argTrigger, argTr, argTheme, argTh, argT, argRestartmode, argRm
    Set argsNamed = WScript.Arguments.Named
    argTrigger = argsNamed.Item("trigger")
    argTr = argsNamed.Item("tr")
    argTheme = argsNamed.Item("theme")
    argTh = argsNamed.Item("th")
    argT = argsNamed.Item("t")
    argRestartmode = argsNamed.Item("restartmode")
    argRm = argsNamed.Item("rm")

    ' trigger
    If Not IsEmpty(argTrigger) Then trigger = ArgGetTrigger(argTrigger)
    If Not IsEmpty(argTr) Then trigger = ArgGetTrigger(argTr)

    ' isThemeDark, strTheme
    If Not IsEmpty(argTheme) Then isThemeDark = ArgIsThemeDark(argTheme)
    If Not IsEmpty(argTh) Then isThemeDark = ArgIsThemeDark(argTh)
    If Not IsEmpty(argT) Then isThemeDark = ArgIsThemeDark(argT)
    If IsEmpty(isThemeDark) Then isThemeDark = Not IsWindowsThemeLight()
    strTheme = "Light"
    If isThemeDark Then strTheme = "Dark"

    ' isRestartModeMinimized
    isRestartModeMinimized = False
    If Not IsEmpty(argRestartmode) Then isRestartModeMinimized = ArgIsRestartModeMinimized(argRestartmode)
    If Not IsEmpty(argRm) Then isRestartModeMinimized = ArgIsRestartModeMinimized(argRm)

    ' doActivateWin, doRefreshAdm, doRestart, doScripts
    doActivateWin = True
    doRefreshAdm = True
    doRestart = False
    doScripts = True
    For Each arg In Wscript.Arguments
        If StrComp(arg, "/restart", vbTextCompare) = 0 Or _
           StrComp(arg, "/r", vbTextCompare) = 0 Then doRestart = True
        If StrComp(arg, "/noScripts", vbTextCompare) = 0 Or _
           StrComp(arg, "/noScr", vbTextCompare) = 0 Then doScripts = False
        If StrComp(arg, "/noAdmRefresh", vbTextCompare) = 0 Or _
           StrComp(arg, "/noAdm", vbTextCompare) = 0 Then doRefreshAdm = False
        If StrComp(arg, "/noActivate", vbTextCompare) = 0 Or _
           StrComp(arg, "/noact", vbTextCompare) = 0 Then doActivateWin = False
    Next
    
    
End Sub

' Restart explorer.exe
Sub RestartExplorer()
    If ((trigger = "BatteryStatusChanged") And isThemeDark) Or doRestart Then
        ' Save active window
        If (objFSO.FileExists("ps\foreground_window.ps1") And doActivateWin) Then
            command = "powershell.exe -noni -nol -nop -ep bypass -f " & _
                """" & objFSO.GetAbsolutePathName("ps\foreground_window.ps1") & """" & " -get"
            Set objExec = objShell.Exec(command)
            activeWinId = objExec.StdOut.ReadLine()
            Set objExec = Nothing
        End If

        ' Restart
        Call Echoo(" > Restart <explorer.exe> and restore tabs", True)
        If objFSO.FileExists("vbs\restart_explorer.vbs") Then
            command = "cscript //nologo ""vbs\restart_explorer.vbs"""
            If isRestartModeMinimized Then command = command & " /minimized"
            Call objShell.Run(command, 0, True)
        Else
            command = "$e='explorer';$t=@();(New-Object -co Shell.Application).Windows()|%{$t+="
            If isRestartModeMinimized Then
                command = command & _
                "$_.Document.Folder.Self.Path};kill -n $e -for;sleep 1;if(!($null=ps $e -ea 0)){saps $e};sleep 5;$t|%{sleep -m 500;saps $_ -win min}"
            Else
                command = command & _
                "@{p=$_.Document.Folder.Self.Path;w=if($_.Top -lt 0){if($_.Top -lt -8000){'min'}else{'max'}}else{'nor'}}};" & _
                "kill -n $e -for;sleep 1;if(!($null=ps $e -ea 0)){saps $e};sleep 5;$t|%{sleep -m 500;saps $_.p -win $_.w}"
            End If
            Call objShell.Run("powershell.exe -noni -nol -nop -ep bypass -c """ & command & """", 0, True)
        End If

        explorerRestarted = True
    End If
End Sub

' Run PS Theme scripts (ps\_adm_helper\*.ps1)
Sub RunPsScripts()
    Dim argg, dir
    argg = " -" & strTheme
    dir = "ps\_adm_helper"
    if (Not doScripts) Or (Not objFSO.FolderExists(dir)) Then Exit Sub

    For Each objFile In objFSO.GetFolder(dir).Files
        If objFSO.GetExtensionName(objFile.Path) = "ps1" Then
            command = "powershell.exe -noni -nol -nop -ep bypass -f " & _
                """" & objFile.Path & """" & " -" & strTheme
            Call Echoo(" > Run '" & dir & "\" & objFile.Name & "'" & argg, True)
            Call objShell.Run(command, 0, False)
        End If
    Next
End Sub

' Refresh ADM theme to fix wallpaper not changing error (force theme toggle)
Sub RefreshAdmTheme()
    ' return if /noadm
    if Not doRefreshAdm Then Exit Sub
    ' return if adm is not running
    Set objWMI = GetObject("winmgmts:\\.\root\cimv2")
    If objWMI.ExecQuery("Select * from Win32_Process Where Name = 'AutoDarkModeSvc.exe'").Count = 0 Then Exit Sub

    'If explorerRestarted Then Call WScript.Sleep(5000)
    Dim admShellExe, admForceTheme
    admShellExe = objShell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Programs\AutoDarkMode\adm-app\AutoDarkModeShell.exe"
    admForceTheme = " --force-light"
    If isThemeDark Then admForceTheme = " --force-dark"
    Call Echoo(" > Refresh ADM theme (force theme toggle)", True)
    Call objShell.Run("""" & admShellExe & """" & admForceTheme, 0, False)
    Call WScript.Sleep(2000)
    Call objShell.Run("""" & admShellExe & """" & " --no-force", 0, False)
    admRefreshed = True
End Sub

' Restore active window (ps\foreground_window.ps1)
Sub RestoreActiveWindow()
    ' return if /noact or if no active window title
    If (Not doActivateWin) Or IsEmpty(activeWinId) Then Exit Sub

    'If Not admRefreshed Then Call WScript.Sleep(7000)
    command = "powershell.exe -noni -nol -nop -ep bypass -f " & _
        """" & objFSO.GetAbsolutePathName("ps\foreground_window.ps1") & """" & " -set " & activeWinId
    Set objExec = objShell.Exec(command)
    result = objExec.StdOut.ReadLine()
    Set objExec = Nothing
    If StrComp(result, "True", vbTextCompare) = 0 Then Call Echoo(" > Restore active window (ps\foreground_window.ps1)", True)
End Sub



' Echo text with Date and Time
Sub Echoo(text, enableDate)
    Dim fullText
    fullText = text
    If enableDate = True Then fullText = FormatDateTimeCustom(Now) & " | " & fullText
    Call WScript.Echo(fullText)
End Sub

Sub EchoArguments()
    Call WScript.Echo(" ")
    Call WScript.Echo("========")
    Call WScript.Echo("Theme: " & strTheme)
    Call WScript.Echo("Trigger: " & trigger)
    Call WScript.Echo(" doActivateWin: " & doActivateWin)
    Call WScript.Echo(" doRefreshAdm: " & doRefreshAdm)
    Call WScript.Echo(" doRestart: " & doRestart)
    Call WScript.Echo(" doScripts: " & doScripts)
    Call WScript.Echo(" isThemeDark: " & isThemeDark)
    Call WScript.Echo(" isRestartModeMinimized: " & isRestartModeMinimized)
    Call WScript.Echo("========")
End Sub

' yyyy-MM-dd HH:mm:ss
Function FormatDateTimeCustom(dt)
    Dim formattedDateTime
    formattedDateTime = Year(dt) & "-" & _
                        Right("0" & Month(dt), 2) & "-" & _
                        Right("0" & Day(dt), 2) & " " & _
                        Right("0" & Hour(dt), 2) & ":" & _
                        Right("0" & Minute(dt), 2) & ":" & _
                        Right("0" & Second(dt), 2)
    FormatDateTimeCustom = formattedDateTime
End Function

' [bool] Check if Windows theme is set to light
Function IsWindowsThemeLight()
    On Error Resume Next
    lightTheme = objShell.RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme")
    On Error GoTo 0
    If lightTheme = 1 Then
        IsWindowsThemeLight = True
    Else
        IsWindowsThemeLight = False
    End If
End Function

Function ArgGetTrigger(text)
    Dim x
    If (StrComp(text, "Any", vbTextCompare) = 0) Then x = "Any"
    If (StrComp(text, "Api", vbTextCompare) = 0) Then x = "Api"
    If (StrComp(text, "BatteryStatusChanged", vbTextCompare) = 0) Then x = "BatteryStatusChanged"
    If (StrComp(text, "ExternalThemeSwitch", vbTextCompare) = 0) Then x = "ExternalThemeSwitch"
    If (StrComp(text, "Manual", vbTextCompare) = 0) Then x = "Manual"
    If (StrComp(text, "NightLightTrackerModule", vbTextCompare) = 0) Then x = "NightLightTrackerModule"
    If (StrComp(text, "Startup", vbTextCompare) = 0) Then x = "Startup"
    If (StrComp(text, "SystemResume", vbTextCompare) = 0) Then x = "SystemResume"
    If (StrComp(text, "SystemUnlock", vbTextCompare) = 0) Then x = "SystemUnlock"
    If (StrComp(text, "TimeSwitchModule", vbTextCompare) = 0) Then x = "TimeSwitchModule"
    ArgGetTrigger = x
End Function

Function ArgIsThemeDark(text)
    Dim x
    If (StrComp(text, "Dark", vbTextCompare) = 0) Or _
       (StrComp(text, "d", vbTextCompare) = 0) Then x = True
    If (StrComp(text, "Light", vbTextCompare) = 0) Or _
       (StrComp(text, "l", vbTextCompare) = 0) Then x = False
    ArgIsThemeDark = x
End Function

Function ArgIsRestartModeMinimized(text)
    Dim x
    x = False
    If (StrComp(text, "Minimized", vbTextCompare) = 0) Or _
       (StrComp(text, "Minimize", vbTextCompare) = 0) Or _
       (StrComp(text, "min", vbTextCompare) = 0) Or _
       (StrComp(text, "m", vbTextCompare) = 0) Then x = True
    ArgIsRestartModeMinimized = x
End Function