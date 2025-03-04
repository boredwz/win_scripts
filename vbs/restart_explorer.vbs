'  RestartExplorer (VBScript)
'  
'  [Author]
'    boredwz | https://github.com/boredwz
'  
'  [Info]
'    Restart <explorer.exe> and restore tabs
'     /minimized or /min: Restore tabs minimized
'  
'  [Example]
'    cscript RestartExplorer.vbs /min

Dim Minimized
Minimized = False
For Each arg In Wscript.Arguments
    If StrComp(arg, "/m", vbTextCompare) = 0 Or _
       StrComp(arg, "/min", vbTextCompare) = 0 Or _
       StrComp(arg, "/minimize", vbTextCompare) = 0 Or _
       StrComp(arg, "/minimized", vbTextCompare) = 0 Then Minimized = True
Next

Set objShell = CreateObject("WScript.Shell")
Set objWindows = CreateObject("Shell.Application").Windows()

Class classExplorerTab
    Public Url
    Public WindowState
End Class

' Save explorer tabs Url and WindowState
Dim listExplorerTabs()
intX = -1
For Each tab In objWindows
    intX = intX + 1
    ReDim Preserve listExplorerTabs(intX)
    Set listExplorerTabs(intX) = New classExplorerTab
    listExplorerTabs(intX).Url = tab.Document.Folder.Self.Path
    listExplorerTabs(intX).WindowState = 1
    If (tab.Top < 0) Then listExplorerTabs(intX).WindowState = 3
    If (tab.Top < -8000) Or (Minimized) Then listExplorerTabs(intX).WindowState = 2
Next

' Kill and restart explorer.exe
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
For Each objProcess in objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'explorer.exe'")
    objProcess.Terminate()
Next
Call WScript.Sleep(1000)
If objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'explorer.exe'").Count = 0 Then
    Call objShell.Run("explorer")
End If
Call WScript.Sleep(5000)

' Restore tabs
If intX <> -1 Then
    For i = 0 To UBound(listExplorerTabs)
        Call WScript.Sleep(500)
        Call objShell.Run(listExplorerTabs(i).Url, listExplorerTabs(i).WindowState, False)
    Next
End If

Call WScript.Quit()