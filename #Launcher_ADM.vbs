' Rename this to <something.vbs> to launch <something.ps1>
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
scriptName = objFSO.GetBaseName(WScript.ScriptName)
arguments = ""
For Each arg In Wscript.Arguments
    arguments = arguments & " " & arg
Next

' Lock file
lock = scriptName & "_lockfile"
If (objFSO.FileExists(lock)) Then WScript.Quit()
Call objFSO.CreateTextFile(lock, True)

' Run ps1
Call objShell.Run("powershell.exe -noe -ep bypass -f """ & scriptName & ".ps1""" & arguments, 0, False)
'Call Wscript.Echo("[" & "powershell.exe -ep bypass -f """ & scriptName & ".ps1""" & arguments & "]")