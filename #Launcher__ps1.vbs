' Rename this to <something.vbs> to launch <something.ps1>
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
name = objFSO.GetBaseName(WScript.ScriptName) & ".ps1"

Call objShell.Run("powershell.exe -ep bypass -f """ & name & """", 0, False)