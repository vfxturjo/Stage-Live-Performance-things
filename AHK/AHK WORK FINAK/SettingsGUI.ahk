#Requires Autohotkey v2
;AutoGUI 2.5.8
;Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter
#Include _deps\helpers.ahk
#Include _deps\_global.ahk

; error log
ErrorList := []

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
	FileMenu.Add("Reload", (*) => (Reload()))
	FileMenu.Add("Exit", (*) => (ExitApp()))
	MenuBar_Storage.Add("&File", FileMenu) ; add it to the storage

	; finally, add it to GUI
	myGui.MenuBar := MenuBar_Storage

	; }

	global statusBar := MyGui.AddStatusBar(, "Status Bar")
	statusBar_setLastError(text) {
		global statusBar
		statusBar.Text := "(check log) Errors found... " text
	}


	; ========= GUI VISUAL VARS ===========

	TabPosition := [5, 100]
	; TA := [10, 30] 		; actual tab usable location offset
	TAx := TabPosition[1] + 5
	TAy := TabPosition[2] + 27
	TabSize := [1200, 400]
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
			kbdUI_keysMap[kbdUI_Keys_id].KeyCode := vals[iniKeyName]
			kbdUI_keysMap[kbdUI_Keys_id].iniKeyName := vals[iniKeyName]

			; { reading INI for settings
			thisKeySetting := IniRead(KeyBindingsFolder "/" KeyBindingsFile, "keys", vals[iniKeyName], "")
			if thisKeySetting != ""
			{
				thisKeySetting := StrSplit(thisKeySetting, A_Space)

				; if first part has error
				if (!IsItemInList(thisKeySetting[1], AvailableFunctions)) {
					statusBar_setLastError("error with " vals[iniKeyName])
					ErrorList.Push(
						"KeyBinding Error:::`tfile: " KeyBindingsFile
						"`tkey: " vals[iniKeyName]
						" `t`t FUNCTION not available"
					)

					kbdUI_keysMap[kbdUI_Keys_id].function := "Not Set"
				}
				else {
					kbdUI_keysMap[kbdUI_Keys_id].function := thisKeySetting[1]
				}

				; if second part has error
				if (thisKeySetting[1] == "app") {
					try {
						if (IsItemInList(thisKeySetting[2], AvailableAppFunctions)) {
							IF thisKeySetting.Length > 2 {
								kbdUI_keysMap[kbdUI_Keys_id].functionMidi := (thisKeySetting[2] . "`n" . thisKeySetting[3])
							}
							else {
								kbdUI_keysMap[kbdUI_Keys_id].functionMidi := ("APP`n" thisKeySetting[2])
							}
						}
						else {
							kbdUI_keysMap[kbdUI_Keys_id].functionMidi := "ERROR"
						}
					} catch Error as e {
						statusBar_setLastError("error with " vals[iniKeyName])
						ErrorList.Push(
							"KeyBinding Error:::`tfile: " KeyBindingsFile
							"`tkey: " vals[iniKeyName]
							" `t`t app -> FUNCTION not available"
						)

						kbdUI_keysMap[kbdUI_Keys_id].functionMidi := " "
					}
				}

				; if second part has error
				if (thisKeySetting[1] == "midi") {
					try {
						if (IsItemInList(thisKeySetting[2], AvailableMidiFunctions)) {
							kbdUI_keysMap[kbdUI_Keys_id].functionMidi := (thisKeySetting[2] . "`n" . thisKeySetting[3])
						}
						else {
							kbdUI_keysMap[kbdUI_Keys_id].functionMidi := "ERROR"
						}
					} catch Error as e {
						statusBar_setLastError("error with " vals[iniKeyName])
						ErrorList.Push(
							"KeyBinding Error:::`tfile: " KeyBindingsFile
							"`tkey: " vals[iniKeyName]
							" `t`t midi -> FUNCTION not available"
						)

						kbdUI_keysMap[kbdUI_Keys_id].functionMidi := " "
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
	Tab.OnEvent("Change", refreshErrorLogList)
	ErrorLogsListBox := myGui.Add("ListBox", "r20 w900", ["ERRORS AND WARNINGS SHOWN HERE"])
	myGui.Add("Button", "yp w100 h100", "⟳").OnEvent("Click", refreshErrorLogList)

	refreshErrorLogList(*) {
		ErrorLogsListBox.Delete()
		ErrorLogsListBox.Add(ErrorList)
	}

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

		inputResult := askForValidInput2("example: C#5", "MidiOut for " button.KeyName, "([a-zA-Z]#\d|[a-zA-Z]\d)")
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

	myGui.Show()

	Return myGui
}
