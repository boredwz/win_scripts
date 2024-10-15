' Rename this to "example123.vbs" to launch "example123.ps1"

Dim objFSO, objShell, scriptBaseName, ps1script, info

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")
scriptBaseName = objFSO.GetBaseName(WScript.ScriptFullName)
ps1script = scriptBaseName & ".ps1"
info = "Rename this to ""example123.vbs"" to launch ""example123.ps1"""

If Not objFSO.FileExists(ps1script) Then
    Call WScript.Echo(info)
    Call WScript.Quit()
End If

command = "powershell.exe -noni -nol -nop -ep bypass -f " & """" & ps1script & """"
Call objShell.Run(command, 0, False)