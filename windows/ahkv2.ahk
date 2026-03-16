#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn
; SetTitleMatchMode 2 ; Allows partial title matching
FileEncoding "UTF-8"
DOTA_WINDOW := "ahk_exe dota2.exe"

; Regular CapsLock behavior - todo: also add for ctrl to not switch on
CapsLock::
{
    if WinActive(DOTA_WINDOW) {
        Send("{Backspace}")
    } else {
        Send("{Ctrl Down}{Shift Down}{Ctrl Up}{Shift Up}")
    }
}

+CapsLock::
{
    if WinActive(DOTA_WINDOW) {
        Send("{Shift Down}{Backspace}{Shift Up}")
    } else {
        Send("{Shift Down}{CapsLock}{Shift Up}")
    }
}

; Ctrl+CapsLock behavior
^CapsLock::
{
    if WinActive(DOTA_WINDOW) {
        Send("{Ctrl Down}{Backspace}{Ctrl Up}")
    } else {
        Send("{Ctrl Down}{CapsLock}{Ctrl Up}")
    }
}
