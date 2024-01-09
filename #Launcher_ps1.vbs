Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
scriptDir = objFSO.GetParentFolderName(WScript.ScriptFullName)

for each file in objFSO.GetFolder(scriptDir).Files
    if InStr(objFSO.GetFileName(file), "#Launcher") = 1 then
        if LCase(objFSO.GetExtensionName(file.Name)) = "ps1" then
            objShell.Run "powershell.exe -ep bypass -f """ & f.Path & """", 0, False
        end if
    end if
next