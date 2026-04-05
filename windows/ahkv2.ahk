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

global gWezTermVisible := false
global gWezTermHwnd := 0
global gWezTermToggling := false

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
    WinWaitActive(gWezTermHwnd,, 1)
    local h := gWezTermHwnd
    SetTimer(() => WinSetAlwaysOnTop(false, h), -100)
}

ToggleWezTerm() {
    global gWezTermVisible, gWezTermHwnd, gWezTermToggling
    if gWezTermToggling
        return
    gWezTermToggling := true
    try {
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
        ; Re-check actual OS visibility to avoid stale state
        actuallyVisible := (WinGetStyle(gWezTermHwnd) & 0x10000000) != 0
        gWezTermVisible := actuallyVisible
        if gWezTermVisible {
            if WinActive(gWezTermHwnd) {
                ; Visible and focused — hide
                WinHide(gWezTermHwnd)
                deadline := A_TickCount + 1000
                while (A_TickCount < deadline) && (WinGetStyle(gWezTermHwnd) & 0x10000000)
                    Sleep(20)
                gWezTermVisible := false
            } else {
                ; Visible but unfocused — just bring to front
                WinSetAlwaysOnTop(true, gWezTermHwnd)
                WinActivate(gWezTermHwnd)
                WinWaitActive(gWezTermHwnd,, 1)
                local h := gWezTermHwnd
                SetTimer(() => WinSetAlwaysOnTop(false, h), -100)
            }
        } else {
            ; Hidden — show, snap, focus
            ShowWezTerm()
            gWezTermVisible := true
        }
    } finally {
        gWezTermToggling := false
    }
}
