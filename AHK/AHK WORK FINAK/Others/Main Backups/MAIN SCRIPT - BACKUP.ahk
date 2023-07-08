#SingleInstance force
Persistent
#include Lib\AutoHotInterception.ahk

AHI := AutoHotInterception()

keyboardId := AHI.GetKeyboardId(0x09DA, 0x2267)

; ======== VARIABLES =========
global CTRL_down := false
global ALT_down := false
global SHIFT_down := false

global previousCode := 0
global previousState := 0

; SUBSCRIBE
AHI.SubscribeKeyboard(keyboardId, true, KeyEvent)

return


; =#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
; ========= Bindings =========
;=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

KeyEvent(code, state) {
	; { global Vars

	global CTRL_down
	global ALT_down
	global SHIFT_down

	; }

	; { ============== NOTE ON/OFF Mode =========

	; check if anything changed!
	global previousCode
	global previousState
	if (previousCode = code) & (previousState = state) {
		return
	}
	else {
		previousCode := code
		previousState := state
	}

	; }


	; basic monitor
	ToolTip("Keyboard Key - Code: " code ", State: " state)

	; ========================= MAIN THING STARTS HERE =================


	; =#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	;=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

	;{ ============ modifiers monitor ===========
	if (state = 1) & (code = 29)
	{
		CTRL_down := 1
		ToolTip("Ctrl Down: " CTRL_down)
	}
	if (state = 0) & (code = 29)
	{
		CTRL_down := 0
		ToolTip("Ctrl Down: " CTRL_down)
	}
	if (state = 1) & (code = 42)
	{
		SHIFT_down := 1
		ToolTip("Shift Down: " SHIFT_down)
	}
	if (state = 0) & (code = 42)
	{
		SHIFT_down := 0
		ToolTip("Shift Down: " CTRL_down)
	}
	if (state = 1) & (code = 56)
	{
		ALT_down := 1
		ToolTip("Alt Down: " CTRL_down)
	}
	if (state = 0) & (code = 56)
	{
		ALT_down := 0
		ToolTip("Alt Down: " CTRL_down)
	}

	;}

	; { =========== modifiers Keys ==============

	; { ======== CTRL =======

	if (CTRL_down = 1) {
		{
			if (state = 1) & (code = 1)
				ExitApp
		}
	}

	;}

	; { ======== SHIFT =======

	if (SHIFT_down = 1) {
		{
			if (state = 1) & (code = 1)
				Reload
		}
	}

	;}

	; { ======== ALT =======

	if (ALT_down = 1) {
		{
			if (state = 1) & (code = 1)
				ExitApp
		}
	}

	;}

	;}

	;{============= Maintenance 2nd keyboard =============================
	if (state) & (code = 69)
	{
		Reload
	}
}


;{============= Maintenance MAIN ======================
^Esc:: ExitApp	; Ctrl+Esc to terminate the script
^!p::Pause    ; Pause script with Ctrl+Alt+P
^!s:: Suspend  ; Suspend script with Ctrl+Alt+S
^!r:: Reload   ; Reload script with Ctrl+Alt+R
;}
