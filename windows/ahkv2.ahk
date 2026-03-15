#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn
SetTitleMatchMode 2 ; Allows partial title matching
FileEncoding "UTF-8"
DOTA_WINDOW := "ahk_exe dota2.exe"

; ================= NEW RULES =================

; 1. Win+Space becomes the Start Menu (Left Win Key)
;#Space::Send "{LWin}"

; 2. Left Win Key becomes Win+Space (Language Switch)
; Logic: If you TAP it, it sends Win+Space. If you HOLD it (e.g. Win+E), it acts like Win.
;~LWin::Send "{Blind}{vkE8}" ; Prevents the native Start Menu from opening on press
;~LWin Up::
;{
;    if (A_PriorKey = "LWin") ; If LWin was the only key pressed
;    {
;        Send "#{Space}"
;    }
;}

; =============================================

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

; ------------------------- Правый Alt (AltGr) -------------------------
; Часть типографской раскладки Ильи Бирмана
RAlt & SC00C::Send "—"        ; AltGr + -  → длинное тире
RAlt & SC003::Send "²"        ; AltGr + 2  → вторая степень
RAlt & SC004::Send "³"        ; AltGr + 3  → третья степень
RAlt & SC005::Send "¼"        ; AltGr + 4  → одна четвёртая
RAlt & SC006::Send "½"        ; AltGr + 5  → одна вторая
RAlt & SC007::Send "¾"        ; AltGr + 6  → три четверти
RAlt & SC008::Send "¿"        ; AltGr + 7  → перевернутый вопрос
RAlt & SC009::Send "∞"        ; AltGr + 8  → бесконечность
RAlt & SC00A::Send "←"        ; AltGr + 9  → стрелка влево
RAlt & SC00B::Send "→"        ; AltGr + 0  → стрелка вправо
RAlt & SC00D::Send "±"        ; AltGr + =  → плюс-минус
RAlt & SC013::Send "®"        ; AltGr + R  → охраняемый знак
RAlt & SC014::Send "™"        ; AltGr + T  → торговая марка
RAlt & SC019::Send "Ø"        ; AltGr + O  → перечеркнутая O
RAlt & SC035::Send "…"        ; AltGr + /  → многоточие
RAlt & SC023::Send "₽"        ; AltGr + H  → российский рубль
RAlt & SC033::Send "«"        ; AltGr + ,  → кавычка-ёлочка левая
RAlt & SC034::Send "»"        ; AltGr + .  → кавычка-ёлочка правая
