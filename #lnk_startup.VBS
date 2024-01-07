'  #lnk_startup (VBS)
'  
'  [Author]
'    wvzxn | https://github.com/wvzxn
'  
'  [Description]
'    Run [*.lnk]s in current folder.
'    [#*.*] - Exception
'    [*_onlyAC.lnk] - only when PC is plugged-in
'    [*_END.lnk] - in the end  + 10 sec pause before run

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Check battery status
set objLocator = CreateObject("WbemScripting.SWbemLocator")
set objServices = objLocator.ConnectServer(".","root\cimv2")
set objResults = objServices.ExecQuery("select * from Win32_Battery")
for each objResult in objResults
    batteryStatus = objResult.BatteryStatus
next

scriptDir = objFSO.GetParentFolderName(WScript.ScriptFullName)
set scriptDirFiles = objFSO.GetFolder(scriptDir).Files

' Run .lnk except [*_END.lnk]
for each f in scriptDirFiles

    if InStr(objFSO.GetFileName(f), "#") <> 1 then      ' filter not [#*.*]
    if LCase(objFSO.GetExtensionName(f)) = "lnk" then   ' filter [*.lnk]

        resultAC = InStrRev(objFSO.GetBaseName(f), "_onlyAC")
        resultEND = InStrRev(objFSO.GetBaseName(f), "_END")

        ' Run except [*_onlyAC.lnk], [*_END.lnk]
        if resultAC + resultEND = 0 then
            objShell.Run """" & f.Path & """", 1, False
            'MsgBox("""" & f.Path & """")
        end if

        ' Run [*_onlyAC.lnk] if Plugged-in
        if resultAC <> 0 then
            if batteryStatus <> 1 then
                objShell.Run """" & f.Path & """", 1, False
                'MsgBox("""" & f.Path & """")
            end if
        end if

    end if
    end if

next

' Run [*_END.lnk]
WScript.Sleep(10000) ' Pause 10 sec
for each f in scriptDirFiles

    if InStr(objFSO.GetFileName(f), "#") <> 1 then      ' filter not [#*.*]
    if LCase(objFSO.GetExtensionName(f)) = "lnk" then   ' filter [*.lnk]

        ' Run [*_END.lnk]
        if InStrRev(objFSO.GetBaseName(f), "_END") <> 0 then
            objShell.Run """" & f.Path & """", 1, False
            'MsgBox("""" & f.Path & """")
        end if

    end if
    end if

next