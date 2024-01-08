Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Check battery status
set objLocator = CreateObject("WbemScripting.SWbemLocator")
set objServices = objLocator.ConnectServer(".","root\cimv2")
set objResults = objServices.ExecQuery("select * from Win32_Battery")
for each objResult in objResults
    batteryStatus = objResult.BatteryStatus
next

if batteryStatus <> 1 then
    ' Plugged-in
    fileArgument = ""
else
    ' On Battery power
    fileArgument = " -Shutdown"
end if

scriptDir = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Execute [*.ps1] files, except [#*.*]
for each f in objFSO.GetFolder(scriptDir).Files
    if InStr(objFSO.GetFileName(f), "#") <> 1 then
        if LCase(objFSO.GetExtensionName(f.Name)) = "ps1" then
            objShell.Run "powershell.exe -ep bypass -f """ & f.Path & """" & fileArgument, 0, False
            'MsgBox("[" & "powershell.exe -ep bypass -f """ & f.Path & fileArgument & """" & "]")
        end if
    end if
next