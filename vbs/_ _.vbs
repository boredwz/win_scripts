Function CheckArgTrigger(text)
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
    CheckArgTrigger = x
End Function

Dim test
Call WScript.Echo(":" & CheckArgTrigger(test) & vbNewLine & IsEmpty(CheckArgTrigger(test)))