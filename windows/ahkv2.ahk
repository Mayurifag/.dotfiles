#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn
DetectHiddenWindows true
; SetTitleMatchMode 2 ; Allows partial title matching
FileEncoding("UTF-8")
SetCapsLockState("AlwaysOff")
DOTA_WINDOW := "ahk_exe dota2.exe"

; Regular CapsLock behavior
CapsLock::
{
  if WinActive(DOTA_WINDOW) {
    Send("{Backspace}")
  } else {
    Send("{Ctrl Down}{Shift Down}{Ctrl Up}{Shift Up}")
  }
}

; Shift+CapsLock behavior
+CapsLock::
{
  if WinActive(DOTA_WINDOW) {
    Send("{Shift Down}{Backspace}{Shift Up}")
  } else {
    Send("{Shift Down}{Shift Up}")
  }
}

; Ctrl+CapsLock behavior
^CapsLock::
{
  if WinActive(DOTA_WINDOW) {
    Send("{Ctrl Down}{Backspace}{Ctrl Up}")
  } else {
    Send("{Ctrl Down}{Ctrl Up}")
  }
}

; Alt+CapsLock behavior
!CapsLock::
{
  if WinActive(DOTA_WINDOW) {
    Send("{Alt Down}{Backspace}{Alt Up}")
  } else {
    Send("{Alt Down}{Alt Up}")
  }
}

; Win+CapsLock behavior
#CapsLock::
{
  if WinActive(DOTA_WINDOW) {
    Send("{LWin Down}{Backspace}{LWin Up}")
  } else {
    Send("{LWin Down}{LWin Up}")
  }
}

; Pre-launch WezTerm hidden so first Alt+` is instant
global gWezTermVisible := false
global gWezTermHwnd := 0
if WinExist("ahk_exe wezterm-gui.exe") {
    ; Adopt an already-running instance (e.g. AHK reloaded)
    gWezTermHwnd := WinGetID("ahk_exe wezterm-gui.exe")
    gWezTermVisible := true
} else {
    Run "C:\Program Files\WezTerm\wezterm-gui.exe"
    SetTimer WaitAndHideWezTerm, 200
}

WaitAndHideWezTerm() {
    global gWezTermVisible, gWezTermHwnd
    if WinExist("ahk_exe wezterm-gui.exe") {
        gWezTermHwnd := WinGetID("ahk_exe wezterm-gui.exe")
        WinHide(gWezTermHwnd)
        gWezTermVisible := false
        SetTimer WaitAndHideWezTerm, 0
    }
}

; WezTerm pseudo-quake toggle (sc029 = physical ` / ё key, layout-independent)
!sc029::ToggleWezTerm()
^sc029::ToggleWezTerm()

; Returns the width of the invisible DWM resize border on the left edge.
; DwmGetWindowAttribute(DWMWA_EXTENDED_FRAME_BOUNDS=9) gives the visible rect;
; GetWindowRect gives the full rect including hidden border — difference is the offset.
GetDwmBorder(hwnd) {
    wRect := Buffer(16, 0)
    fRect := Buffer(16, 0)
    DllCall("GetWindowRect", "ptr", hwnd, "ptr", wRect)
    DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "uint", 9, "ptr", fRect, "uint", 16)
    return NumGet(fRect, 0, "int") - NumGet(wRect, 0, "int")
}

ShowWezTerm() {
    global gWezTermHwnd
    WinShow(gWezTermHwnd)
    border := GetDwmBorder(gWezTermHwnd)
    WinMove(-border, 0, A_ScreenWidth + border * 2,, gWezTermHwnd)
    WinSetAlwaysOnTop(true, gWezTermHwnd)
    WinActivate(gWezTermHwnd)
    local h := gWezTermHwnd
    SetTimer(() => WinSetAlwaysOnTop(false, h), -100)
}

ToggleWezTerm() {
    global gWezTermVisible, gWezTermHwnd
    if !gWezTermHwnd || !WinExist(gWezTermHwnd) {
        gWezTermVisible := false
        gWezTermHwnd := 0
        Run "C:\Program Files\WezTerm\wezterm-gui.exe"
        WinWait("ahk_exe wezterm-gui.exe",, 15)
        gWezTermHwnd := WinGetID("ahk_exe wezterm-gui.exe")
        ShowWezTerm()
        gWezTermVisible := true
        return
    }
    if gWezTermVisible {
        if WinActive(gWezTermHwnd) {
            ; Visible and focused — hide
            WinHide(gWezTermHwnd)
            gWezTermVisible := false
        } else {
            ; Visible but unfocused — just bring to front
            WinSetAlwaysOnTop(true, gWezTermHwnd)
            WinActivate(gWezTermHwnd)
            local h := gWezTermHwnd
            SetTimer(() => WinSetAlwaysOnTop(false, h), -100)
        }
    } else {
        ; Hidden — show, snap, focus
        ShowWezTerm()
        gWezTermVisible := true
    }
}
