#SingleInstance force
Persistent
#include Lib\AutoHotInterception.ahk

AHI := AutoHotInterception()

keyboardId := AHI.GetKeyboardId(0x09DA, 0x2267)						; <<------ Change it
AHI.SubscribeKeyboard(keyboardId, true, KeyEvent)

return

KeyEvent(code, state) {
	; ToolTip("Keyboard Key - Code: " code ", State: " state)

	; ========================= MAIN THING STARTS HERE =================
	if (state) & (code = 29)
	{
		if (code = 1)
		{
			MsgBox("aaa", "works")
		}
	}


	if (code = 29) & (state = 1) {
		if (code = 1) {
			MsgBox("aaa", "works")
		}
	}

}


;{============= Maintenance =============================
^Esc:: ExitApp	; Ctrl+Esc to terminate the script
^!p::Pause    ; Pause script with Ctrl+Alt+P
^!s:: Suspend  ; Suspend script with Ctrl+Alt+S
^!r:: Reload   ; Reload script with Ctrl+Alt+R
;}
