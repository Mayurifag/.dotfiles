#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn
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

; Launch Windows Terminal in quake mode if not already running.
; When WT is running, these keys pass through to WT's own globalSummon handler.
#HotIf !ProcessExist("WindowsTerminal.exe")
^vkC0::Run("wt.exe -w _quake")
!vkC0::Run("wt.exe -w _quake")
#HotIf

; RAlt typography layer (ported from kanata; kanata dropped on Windows
; because its Interception driver prevents espanso from detecting keystrokes).
>!-::SendText("—")
>!2::SendText("²")
>!3::SendText("³")
>!4::SendText("¼")
>!5::SendText("½")
>!6::SendText("¾")
>!7::SendText("¿")
>!8::SendText("∞")
>!9::SendText("←")
>!0::SendText("→")
>!=::SendText("±")
>!r::SendText("®")
>!t::SendText("™")
>!p::SendText("Ø")
>!/::SendText("…")
>!h::SendText("₽")
>!,::SendText("«")
>!.::SendText("»")
