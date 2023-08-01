#Requires Autohotkey v2
;AutoGUI 2.5.8
;Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter
#Include helpers.ahk

; error log
ErrorList := []

; { READING CSV
kbdUI_AllKBDinfo := Map()

KeyGroup := 1
KeyName := 2
iniKeyName := 3
Xpos := 4
Ypos := 5
Xsize := 6
Ysize := 7
KeyCode := 8

TotalNumOfKeys := 0

Loop read, "csv/KeyboardButtonInfos nikhut.csv"
{
	LineNumber := A_Index
	if (LineNumber == 1)
		continue

	tempObj := []
	Loop parse, A_LoopReadLine, "CSV"
	{
		; skipping first line
		tempObj.Push(A_LoopField)
		TotalNumOfKeys++
	}

	; AllKBDinfo.Push([LineNumber, tempObj])
	kbdUI_AllKBDinfo.Set(LineNumber - 1, tempObj)
}

; }


; { reading settings
;Filename := "settings.ini"
;Section := "general"
; }

; { reading keyBinding files
KeyBindingsFile := IniRead("settings.ini", "general", "currentKeyBindingsFileName", "")
KeyBindingsFolder := IniRead("settings.ini", "general", "keyBindingsFolder", "")

refresh_keyBindings_Files(*) {
	global KeyBindingsFileList := []
	loop files (keyBindingsFolder "/*.ini") {
		KeyBindingsFileList.Push(A_LoopFileName)
	}
}
refresh_keyBindings_Files()

; reading keyBindings and files
; TODO: if file not found, then what?
Section := "keys"
AvailableFunctions := ["midi"]
; }


CreateGUI()


; LShift:: {
#hotif WinActive("ahk_class AutoHotkeyGUI")
; SHOW THE MIDI KEYS
`::
{
	showMidiOutNamesOnButtons()

	while GetKeyState(A_ThisHotkey, "P") { ; do nothing if pressed
	}

	showKeyNamesOnButtons()
}


#HotIf

respondToKeyInGui(key) {
	MsgBox(key)
}


showMidiOutNamesOnButtons() {
	for key, button in kbdUI_keysMap {
		try  ; Attempts to execute code.
		{
			button.Text := button.functionMidi
		}
		catch as e  ; Handles the first error thrown by the block above.
		{
			ErrorList.Push("Error: for file " KeyBindingsFile ", for key " button.KeyName " (keycode: " key ")!`nSpecifically: " e.Message)
		}
	}
	refresh_kbdUICurrentInfoBanner("Showing Midi Out Names")
}
showKeyNamesOnButtons() {
	for key, button in kbdUI_keysMap {
		button.Text := button.KeyName
	}
	refresh_kbdUICurrentInfoBanner()
}
refresh_kbdUICurrentInfoBanner(text := "Showing Keyboard keys") {
	kbdUI_currentInfoBanner.Text := (KeyBindingsFile " =  " text)
}
checkButtons() {
	showMidiOutNamesOnButtons()
	showKeyNamesOnButtons()
}

; Pause
return


CreateGUI() {
	; ========= GLOBAL VARS ===========
	global KeyBindingsFile
	global KeyBindingsFileList

	myGui := Gui()

	; Maintainance
	myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "SecondKeyboard Configurator"

	; { MENUBAR of Gui
	MenuBar_Storage := MenuBar() ; add everything here

	FileMenu := Menu() ; initialize a menu
	; FileMenu.Add("exit", exitFunc)
	MenuBar_Storage.Add("&File", FileMenu) ; add it to the storage

	; finally, add it to GUI
	myGui.MenuBar := MenuBar_Storage

	; }


	; ========= GUI VISUAL VARS ===========

	TabPosition := [5, 100]
	; TA := [10, 30] 		; actual tab usable location offset
	TAx := TabPosition[1] + 5
	TAy := TabPosition[2] + 27
	TabSize := [1050, 360]
	Tabs := ["KeyboardUI", "ErrorLog"]


	; params:
	; single line: +0x200
	; border: +Border
	; 3d subken edge:  +E0x200


	; { =====  Settings ini selector =====
	myGui.Add("GroupBox", "Section r2 w200", "Key Bindings ini")
	; drop down
	KeyBindingsFile_DropDown := myGui.Add("DropDownList", "xp10 yp20 wp-60", KeyBindingsFileList)
	KeyBindingsFile_DropDown.Value := indexOfItemInList(KeyBindingsFile, KeyBindingsFileList)

	KeyBindingsFile_DropDown.OnEvent("Change", KeyBindingsFile_DropDown_changed)
	KeyBindingsFile_DropDown_changed(*) {
		global KeyBindingsFile := KeyBindingsFileList[KeyBindingsFile_DropDown.Value]
		IniWrite(KeyBindingsFile,
			"settings.ini", "general", "currentKeyBindingsFileName")
		createKeyboardUI()
		checkButtons()
	}
	; refresh Button
	myGui.Add("Button", "yp", "⟳").OnEvent("Click", (*) => (
		refresh_keyBindings_Files()
		KeyBindingsFile_DropDown.Delete()
		KeyBindingsFile_DropDown.Add(KeyBindingsFileList)
		KeyBindingsFile_DropDown.Value := indexOfItemInList(KeyBindingsFile, KeyBindingsFileList)
		checkButtons()))
	; }


	; ===================================== TABS

	Tab := myGui.Add("Tab3", "x" TabPosition[1] " y" TabPosition[2] " w" TabSize[1] " h" TabSize[2], Tabs)

	; configuring Tab 1
	Tab.UseTab(1)
	; { keyboard UI layout Settings
	createKeyboardUI() {
		kbdUI_InfoBannerHeight := 20

		kbdUI_ContentsSpacingX := 5
		kbdUI_ContentsSpacingY := 5
		kbdUI_padding := 5
		kbdUI_Ypadding := 25
		kbdUI_defaultButtonSize := 40

		; keyboard UI layout main
		global kbdUI_currentInfoBanner := myGui.Add("Text", "x10 y" TabPosition[2] + kbdUI_Ypadding " w" TabSize[1] - 15 " h20 +0x200 +Border", KeyBindingsFileList[KeyBindingsFile_DropDown.Value] " = " " Showing Keyboard keys")

		kbdUI_Keys_id := 1
		global kbdUI_keysMap := Map()
		for entry in kbdUI_AllKBDinfo {
			vals := kbdUI_AllKBDinfo[entry]

			; calculating coordinates
			thisButtonX := TabPosition[1] + kbdUI_padding + (vals[Xpos]) * (kbdUI_defaultButtonSize + kbdUI_ContentsSpacingX)
			thisButtonY := TabPosition[2] + kbdUI_Ypadding + kbdUI_InfoBannerHeight + 10 + (vals[Ypos]) * (kbdUI_defaultButtonSize + kbdUI_ContentsSpacingY)
			thisButtonXsize := vals[Xsize] * kbdUI_defaultButtonSize
			thisButtonYsize := vals[Ysize] * kbdUI_defaultButtonSize

			; adding button to GUI and list
			kbdUI_keysMap[kbdUI_Keys_id] := myGui.Add("Button", "x" thisButtonX " y" thisButtonY " w" thisButtonXsize " h" thisButtonYsize, vals[KeyName])

			; storing data
			kbdUI_keysMap[kbdUI_Keys_id].KeyGroup := vals[KeyGroup]
			kbdUI_keysMap[kbdUI_Keys_id].KeyName := vals[KeyName]
			kbdUI_keysMap[kbdUI_Keys_id].KeyCode := vals[KeyCode]
			kbdUI_keysMap[kbdUI_Keys_id].iniKeyName := vals[iniKeyName]

			; { reading INI for settings
			thisKeySetting := IniRead(KeyBindingsFolder "/" KeyBindingsFile, "keys", vals[iniKeyName], "")
			if thisKeySetting != ""
			{
				thisKeySetting := StrSplit(thisKeySetting, A_Space)

				; if first part has error
				if (!IsItemInList(thisKeySetting[1], AvailableFunctions)) {
					ToolTip("THERE ARE SOME ERROR IN INI FILE, CHECK FUNCTIONS")
					kbdUI_keysMap[kbdUI_Keys_id].function := "Not Set"
				}
				else {
					kbdUI_keysMap[kbdUI_Keys_id].function := thisKeySetting[1]
				}

				; if second part has error
				if (thisKeySetting[1] == "midi") {
					if thisKeySetting.Length != 2 {
						ToolTip("THERE ARE SOME ERROR IN INI FILE, CHECK MIDI PARAMs")
						kbdUI_keysMap[kbdUI_Keys_id].functionMidi := " "
					}
					else {
						kbdUI_keysMap[kbdUI_Keys_id].functionMidi := thisKeySetting[2]
					}
				}
			}
			else {
				; if no values found
				kbdUI_keysMap[kbdUI_Keys_id].function := "Not Set"
				kbdUI_keysMap[kbdUI_Keys_id].functionMidi := " "
			}
			; }


			; event handler
			kbdUI_keysMap[kbdUI_Keys_id].OnEvent("Click", onKeyboardUIButtonClick)

			kbdUI_Keys_id++
		}
	}
	createKeyboardUI()
	; }

	; { configuring tab 2

	Tab.UseTab(2)
	ErrorLogsListBox := myGui.Add("ListBox", "r20 w700", ["ERRORS AND WARNINGS SHOWN HERE"])
	myGui.Add("Button", "yp", "⟳").OnEvent("Click", (*) => (
		ErrorLogsListBox.Delete()
		ErrorLogsListBox.Add(ErrorList))
	)

	; }

	;
	;
	;
	;
	;
	; =============== EVENT HANDLERS =======================
	;


	onKeyboardUIButtonClick(button, *)
	{
		button.Text := "EDITING`nTHIS"

		inputResult := askForValidInput("example: C#5", "MidiOut for " button.KeyName, "([a-zA-Z]#\d|[a-zA-Z]\d)")
		if (inputResult != -1) {

			IniWrite("midi " inputResult, KeyBindingsFile, Section, button.iniKeyName)

			button.functionMidi := inputResult
			button.Text := inputResult


			SetTimer(getBackToOriginalText, -500)
		}
		else {
			getBackToOriginalText()
		}

		getBackToOriginalText() {
			button.Text := button.KeyName
		}


	}


	; { show GUI
	ogSB := MyGui.AddStatusBar(, "Status Bar")
	myGui.Show()
	; }
	Return myGui
}
