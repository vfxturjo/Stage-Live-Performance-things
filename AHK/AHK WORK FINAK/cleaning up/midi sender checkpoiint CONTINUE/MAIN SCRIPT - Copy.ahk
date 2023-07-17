#SingleInstance force
Persistent
#include Lib\AutoHotInterception.ahk
#Include inspired2.ahk

AHI := AutoHotInterception()

keyboardId := AHI.GetKeyboardId(0x09DA, 0x2267)

; ======== VARIABLES =========
global CTRL_down := false
global ALT_down := false
global SHIFT_down := false
global octaveOffset := 0
global noteOffset := 0
global maxOffset := 36
global velocity := 100

global previousCode := 0
global previousState := 0

; SUBSCRIBE
AHI.SubscribeKeyboard(keyboardId, true, KeyEvent)


; =#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
; ========= EZ Funcs =========
;=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

tt(text) {
	ToolTip(text)
}

noteId(note)
{
	; Extract note name and octave using regex
	match := []
	regexMatch(note, "(\D+)(\d+)", &match)
	; note_name := match[1] ,,,,, octave := match[2]
	return 12 * match[2] + Map(
		"C", 0,
		"C#", 1,
		"D", 2,
		"D#", 3,
		"E", 4,
		"F", 5,
		"F#", 6,
		"G", 7,
		"G#", 8,
		"A", 9,
		"A#", 10,
		"B", 11
	)[match[1]]
}


; ; velocity mappings
volumesObj := Map(1, 40, 2, 70, 3, 90, 4, 120)


; ;  Midi Keymappings

; Full keyboard mapping
notesMidiObj := Map(
	59, 0, 60, 0, 61, 0, 62, 0, 63, 0, 64, 0, 65, 0, 66, 0, 67, 0, 68, 0, 87, 0, 88, 0, 2, 0, 3, 73, 4, 75, 5, 0, 6, 78, 7, 80, 8, 82, 9, 0, 10, 85, 11, 87, 12, 0, 13, 90, 16, 72, 17, 74, 18, 76, 19, 77, 20, 79, 21, 81, 22, 83, 23, 84, 24, 86, 25, 88, 26, 89, 27, 91, 30, 0, 31, 61, 32, 63, 33, 0, 34, 66, 35, 68, 36, 70, 37, 0, 38, 73, 39, 75, 40, 0, 0, 0, 44, 60, 45, 62, 46, 64, 47, 65, 48, 67, 49, 69, 50, 71, 51, 72, 52, 74, 53, 76, 1, 0, 41, 0, 15, 0, 58, 0, 14, 0, 284, 0, 42, 0, 310, 0, 29, 0, 285, 0, 56, 0, 312, 0, 57, 0, 311, 0, 70, 0, 325, 0, 338, 0, 327, 0, 329, 0, 339, 0, 335, 0, 337, 0, 328, 0, 336, 0, 331, 0, 333, 0, 82, 0, 79, 0, 80, 0, 81, 0, 75, 0, 76, 0, 77, 0, 71, 0, 72, 0, 73, 0, 309, 0, 82, 0, 74, 0, 78, 0, 325, 0, 284, 0, 83, 0
)

; Diatonic Scale
notesMidiObj := Map(
	59, 0, 60, 0, 61, 0, 62, 0, 63, 0, 64, 0, 65, 0, 66, 0, 67, 0, 68, 0, 87, 0, 88, 0, 2, 96, 3, 98, 4, 100, 5, 101, 6, 103, 7, 105, 8, 107, 9, 108, 10, 110, 11, 112, 12, 113, 13, 115, 16, 84, 17, 86, 18, 88, 19, 89, 20, 91, 21, 93, 22, 95, 23, 96, 24, 98, 25, 100, 26, 101, 27, 103, 30, 72, 31, 74, 32, 76, 33, 77, 34, 79, 35, 81, 36, 83, 37, 84, 38, 86, 39, 88, 40, 89, 0, 91, 44, 60, 45, 62, 46, 64, 47, 65, 48, 67, 49, 69, 50, 71, 51, 72, 52, 74, 53, 76, 1, 0, 41, 0, 15, 0, 58, 0, 14, 0, 284, 0, 42, 0, 310, 0, 29, 0, 285, 0, 56, 0, 312, 0, 57, 0, 311, 0, 70, 0, 325, 0, 338, 0, 327, 0, 329, 0, 339, 0, 335, 0, 337, 0, 328, 0, 336, 0, 331, 0, 333, 0, 82, 0, 79, 0, 80, 0, 81, 0, 75, 0, 76, 0, 77, 0, 71, 0, 72, 0, 73, 0, 309, 0, 82, 0, 74, 0, 78, 0, 325, 0, 284, 0, 83, 0
)


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

	now_note := notesMidiObj[code] + octaveOffset + noteOffset

	; basic monitor
	; ToolTip("Keyboard Key - Code: " code ", State: " state)
	ToolTip("Midi Note: " now_note ", State: " state)

	if (notesMidiObj[code] != 0) {
		playMini(now_note * (state == 0 ? -1 : 1), 0, velocity)
	}

	; =#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	;=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

	; Go from ScanCode to normal key name:
	; GetKeyName(67) => f9 (Function 9 button)
	; Go from normal key name to ScanCode:
	; GetKeySC("f9") => 67

	; ========================= MAIN THING STARTS HERE =================


	; { SHIFTERS

	; OCTAVE SHIFTER
	if (state == 1) & (code == 328) {
		if (Abs(octaveOffset + noteOffset) + 12 < maxOffset) { ; if not exceeding maxOffset
			global octaveOffset := octaveOffset + 12

			ToolTip("Total Offset: " octaveOffset + noteOffset)
		}
	}
	if (state == 1) & (code == 336) {
		if (Abs(octaveOffset + noteOffset) + 12 < maxOffset) { ; if not exceeding maxOffset
			global octaveOffset := octaveOffset - 12
			ToolTip("Total Offset: " octaveOffset + noteOffset)
		}
	}
	; NOTE SHIFTER
	if (state == 1) & (code == 331) {
		if (Abs(octaveOffset + noteOffset) - 1 < maxOffset) { ; if not exceeding maxOffset
			global noteOffset := noteOffset - 1
			ToolTip("Total Offset: " octaveOffset + noteOffset)
		}
	}
	if (state == 1) & (code == 333) {
		if (Abs(octaveOffset + noteOffset) + 1 < maxOffset) { ; if not exceeding maxOffset
			global noteOffset := noteOffset + 1
			ToolTip("Total Offset: " octaveOffset + noteOffset)
		}
	}

	;}

	; VELOCITY SETTER
	if (state == 1) & (code == 59) {
		global velocity := volumesObj[1]
	}
	if (state == 1) & (code == 60) {
		global velocity := volumesObj[2]
	}
	if (state == 1) & (code == 61) {
		global velocity := volumesObj[3]
	}
	if (state == 1) & (code == 62) {
		global velocity := volumesObj[4]
	}


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
