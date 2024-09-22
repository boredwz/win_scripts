#  Foreground Window [-Get/-Set <hwnd>] (PowerShell)
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
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
}
public class WinAPI {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool IsWindow(IntPtr hWnd);
}
"@

if ($GetHwnd) {
    return [User32]::GetForegroundWindow()
} else {
    if ($Activate -notmatch '^\d+$') {return $false}
    try {
        $hwnd = [int]$Activate
        if (!([WinAPI]::IsWindow([IntPtr]::new($hwnd)))) {return $false} # Is not exist
        $null = [User32]::keybd_event(0x11, 0, 0, [UIntPtr]::Zero)  # Ctrl key down
        $result = [User32]::SetForegroundWindow($hwnd)
        $null = [User32]::keybd_event(0x11, 0, 2, [UIntPtr]::Zero)  # Ctrl key up
        return $result
    } catch {}
    return $false
}