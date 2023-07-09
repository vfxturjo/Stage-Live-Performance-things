#Requires Autohotkey v2
;AutoGUI 2.5.8
;Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter


AllKBDinfo := Map()
; { READING CSV
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


CreateGUI()

LShift:: {
	global tab1keysMap

	for key, button in tab1keysMap {
		button.Text := button.SendMidi
	}
	; backupVals := []
	; for key, button in tab1keysMap {
	; 	backupVals.Push(button.Text)
	; 	button.Text := 3
	; }

	while GetKeyState(A_ThisHotkey, "P") {
	}


	for key, button in tab1keysMap {
		button.Text := button.KeyName
	}
}


; Pause
return


CreateGUI() {

	myGui := Gui()

	; Maintainance
	myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "Window"

	; { MENUBAR of Gui
	MenuBar_Storage := MenuBar() ; add everything here

	FileMenu := Menu() ; initialize a menu
	; FileMenu.Add("exit", exitFunc)
	MenuBar_Storage.Add("&File", FileMenu) ; add it to the storage

	; finally, add it to GUI
	myGui.MenuBar := MenuBar_Storage

	; }


	; ========= GUI VISUAL VARS ===========

	TabPosition := [5, 3]
	TabSize := [1200, 400]
	Tabs := ["Tab 1", "Tab 2"]

	tabContentsSpacingX := 5
	tabContentsSpacingY := 5
	padding := 5
	tabYpadding := 25
	defaultButtonSize := 40

	tabContentsMaxX := 0
	tabContentsMaxY := 0


	; =====================================


	Tab := myGui.Add("Tab3", "x" TabPosition[1] " y" TabPosition[2] " w" TabSize[1] " h" TabSize[2], Tabs)

	; configuring Tab 1
	Tab.UseTab(1)

	; myGui.Add("Button", "x176 y128 w42 h33", "&OK").OnEvent("Click", OnEventHandler)


	; { show GUI
	ogSB := MyGui.AddStatusBar(, "Status Bar")
	myGui.Show()
	; }


	temp_tab1keys_id := 1
	global tab1keysMap := Map()
	for entry in AllKBDinfo {
		KeyGroup := 1
		KeyName := 2
		Xpos := 3
		Ypos := 4
		KeyCode := 5

		vals := AllKBDinfo[entry]


		thisButtonX := TabPosition[1] + padding + (vals[Xpos]) * (defaultButtonSize + tabContentsSpacingX)
		thisButtonY := TabPosition[2] + tabYpadding + (vals[Ypos]) * (defaultButtonSize + tabContentsSpacingY)


		tab1keysMap[temp_tab1keys_id] := myGui.Add("Button", "x" thisButtonX " y" thisButtonY " w" defaultButtonSize " h" defaultButtonSize, vals[KeyName])

		; storing data
		tab1keysMap[temp_tab1keys_id].KeyGroup := vals[KeyGroup]
		tab1keysMap[temp_tab1keys_id].KeyName := vals[KeyName]
		tab1keysMap[temp_tab1keys_id].KeyCode := vals[KeyCode]
		tab1keysMap[temp_tab1keys_id].SendMidi := 0


		tab1keysMap[temp_tab1keys_id].OnEvent("Click", onTab1ButtonClick)

		temp_tab1keys_id++

		;
		; track highest X and Y
		if (thisButtonX > tabContentsMaxX) {
			tabContentsMaxX := thisButtonX
		}
		if (thisButtonY > tabContentsMaxY) {
			tabContentsMaxY := thisButtonY
		}

	}

	; show max size
	; MsgBox("max sizes: " tabContentsMaxX ", " tabContentsMaxY)

	;
	;
	;
	; =============== EVENT HANDLERS =======================
	;


	onTab1ButtonClick(a, *)
	{
		if !a.HasProp("originalText") {
			a.originalText := a.Text
		}

		a.Text := "Clicked!"

		SetTimer(changeText, -400)		; waits 400 miliseconds
		changeText() {    ; runs after 400 ms
			a.Text := a.originalText
			a.timerRunning := 0
		}


		IB := InputBox("example: C#5", "MidiOut for " a.KeyName, "w150 h100")
		if (IB.Result != "Cancel")
			; MsgBox "You entered '" IB.Value "' but then cancelled."
			; else {
			a.SendMidi := IB.Value


		ToolTip("Click! This is a sample action.`n", 77, 277)
		SetTimer () => ToolTip(), -3000 ; tooltip timer
	}


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
