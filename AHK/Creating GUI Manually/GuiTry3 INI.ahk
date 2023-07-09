#Requires Autohotkey v2
;AutoGUI 2.5.8
;Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter
#Include helpers.ahk


; { READING CSV
AllKBDinfo := Map()

KeyGroup := 1
KeyName := 2
iniKeyName := 3
Xpos := 4
Ypos := 5
KeyCode := 6

Loop read, "KeyboardButtonInfos.csv"
{
	LineNumber := A_Index
	if (LineNumber == 1)
		continue

	tempObj := []
	Loop parse, A_LoopReadLine, "CSV"
	{
		; skipping first line
		tempObj.Push(A_LoopField)
	}

	; AllKBDinfo.Push([LineNumber, tempObj])
	AllKBDinfo.Set(LineNumber - 1, tempObj)
}

; }

; { reading settings
Filename := "settings.ini"
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

showMidiOutNamesOnButtons() {
	for key, button in tab1keysMap {
		button.Text := button.functionMidi
	}
	MouseShowMidiNamesText.Text := " Showing Midi Out Names"
}
showKeyNamesOnButtons() {
	for key, button in tab1keysMap {
		button.Text := button.KeyName
	}

	MouseShowMidiNamesText.Text := " Showing Keyboard keys"
}

; Pause
return


CreateGUI() {

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

	TabPosition := [5, 28]
	TabSize := [1200, 400]
	Tabs := ["Tab 1", "Tab 2"]

	tabContentsSpacingX := 5
	tabContentsSpacingY := 5
	padding := 5
	tabYpadding := 25
	defaultButtonSize := 40

	; ; ; for tracking highest coordinates
	; tabContentsMaxX := 0
	; tabContentsMaxY := 0


	; params:
	; single line: +0x200
	; border: +Border
	; 3d subken edge:  +E0x200
	global MouseShowMidiNamesText := myGui.Add("Text", "x5 y5 w1200 h20 +0x200 +Border", " Showing Keyboard keys")


	; ===================================== TABS

	Tab := myGui.Add("Tab3", "x" TabPosition[1] " y" TabPosition[2] " w" TabSize[1] " h" TabSize[2], Tabs)

	; configuring Tab 1
	Tab.UseTab(1)


	temp_tab1keys_id := 1
	global tab1keysMap := Map()
	for entry in AllKBDinfo {
		vals := AllKBDinfo[entry]

		; calculating coordinates
		thisButtonX := TabPosition[1] + padding + (vals[Xpos]) * (defaultButtonSize + tabContentsSpacingX)
		thisButtonY := TabPosition[2] + tabYpadding + (vals[Ypos]) * (defaultButtonSize + tabContentsSpacingY)

		; adding button to GUI and list
		tab1keysMap[temp_tab1keys_id] := myGui.Add("Button", "x" thisButtonX " y" thisButtonY " w" defaultButtonSize " h" defaultButtonSize, vals[KeyName])

		; storing data
		tab1keysMap[temp_tab1keys_id].KeyGroup := vals[KeyGroup]
		tab1keysMap[temp_tab1keys_id].KeyName := vals[KeyName]
		tab1keysMap[temp_tab1keys_id].KeyCode := vals[KeyCode]
		tab1keysMap[temp_tab1keys_id].iniKeyName := vals[iniKeyName]

		; { reading INI for settings
		thisKeySetting := IniRead(Filename, Section, vals[iniKeyName], "")
		if thisKeySetting != ""
		{
			thisKeySetting := StrSplit(thisKeySetting, A_Space)

			; if first part has error
			if (!IsItemInList(thisKeySetting[1], AvailableFunctions)) {
				ToolTip("THERE ARE SOME ERROR IN INI FILE, CHECK FUNCTIONS")
				tab1keysMap[temp_tab1keys_id].function := "Not Set"
			}
			else {
				tab1keysMap[temp_tab1keys_id].function := thisKeySetting[1]
			}

			; if second part has error
			if (thisKeySetting[1] == "midi") {
				if thisKeySetting.Length != 2 {
					ToolTip("THERE ARE SOME ERROR IN INI FILE, CHECK MIDI PARAMs")
					tab1keysMap[temp_tab1keys_id].functionMidi := " "
				}
				else {
					tab1keysMap[temp_tab1keys_id].functionMidi := thisKeySetting[2]
				}
			}
		}
		else {
			; if no values found
			tab1keysMap[temp_tab1keys_id].function := "Not Set"
			tab1keysMap[temp_tab1keys_id].functionMidi := " "
		}
		; }


		; event handler
		tab1keysMap[temp_tab1keys_id].OnEvent("Click", onTab1ButtonClick)

		temp_tab1keys_id++
	}

	;
	;
	;
	;
	;
	; =============== EVENT HANDLERS =======================
	;


	onTab1ButtonClick(button, *)
	{
		button.Text := "EDITING`nTHIS"

		inputResult := askForValidInput("example: C#5", "MidiOut for " button.KeyName, "([a-zA-Z]#\d|[a-zA-Z]\d)")
		if (inputResult != -1) {

			IniWrite("midi " inputResult, Filename, Section, button.iniKeyName)

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


;
;


;
;
; ; ; Styling helpers
; name := "JimKarvo"
; myGui := Gui()
; myGui.Add("Text", , "Hello," . A_Space)
; myGui.SetFont("bold")
; myGui.Add("Text", "X+0", name)
; myGui.SetFont()
; myGui.Add("Text", "X+0", "!")

; myGui := Gui()
; myGui.SetFont("s8 bold", "Tahoma")
; ogcButtonVerifytheaddress := myGui.Add("Button", "-Wrap w300", "&Verify the address")
; ; ogcButtonVerifytheaddress.OnEvent("Click", VerifyAddress.Bind("Normal"))
; myGui.Show()

;
;
;;
;
;
; DO something on button Up
;; Re: Activate on button up not button.  Topic is solved
;; @
;; 24 Dec 2018, 08:45
;; I will help you because it's Christmas and your question actually sounds legit this time.
;; Code: Select all - Download - Toggle Line numbers

; $rbutton:: ; Right mouse button
; Send {rbutton} ; Press right mouse button
; while GetKeyState("rbutton", "P") ; While right mouse button is being held:
; { } ; Don't do anything - After it has been released:
; Send {rbutton} ; Press again right mouse button
; return
