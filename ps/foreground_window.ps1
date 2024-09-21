#  Foreground Window [-Get/-Set <id>] (PowerShell)
param(
    [Parameter(Mandatory=$true,ParameterSetName="1")][alias("get","id")][switch]$GetHwnd,
    [AllowNull()][AllowEmptyString()][Parameter(Mandatory=$true,ParameterSetName="2")][alias("act","show","set")][string]$Activate
)

Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class User32 {
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
    }
"@

if ($GetHwnd) {
    return [User32]::GetForegroundWindow()
} else {
    if ([string]::IsNullOrEmpty($Activate)) {return $false}
    try {
        return [User32]::SetForegroundWindow([int]$Activate)
    } catch {}
    return $false
}