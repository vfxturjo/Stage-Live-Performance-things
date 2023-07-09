#Requires Autohotkey v2
;AutoGUI 2.5.8
;Auto-GUI-v2 credit to Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter credit to github.com/mmikeww/AHK-v2-script-converter


AllKBDinfo := Map()
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


gui1 := CreateGUI()

LShift:: {
	global keysList

	backupVals := []
	for key, button in keysList {
		backupVals.Push(button.Text)
		button.Text := 3
	}

	while GetKeyState(A_ThisHotkey, "P") {
	}


	for key, button in keysList {
		button.Text := backupVals[key]
	}
}


; Pause
return


CreateGUI() {

	myGui := Gui()

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
	TabSize := [1000, 400]
	Tabs := ["Tab 1", "Tab 2"]

	tabContentsSpacingX := 10
	tabContentsSpacingY := 10
	padding := 5
	tabYpadding := 25
	defaultButtonSize := 40


	; =====================================


	Tab := myGui.Add("Tab3", "x" TabPosition[1] " y" TabPosition[2] " w" TabSize[1] " h" TabSize[2], Tabs)

	; configuring Tab 1
	Tab.UseTab(1)

	; myGui.Add("Button", "x176 y128 w42 h33", "&OK").OnEvent("Click", OnEventHandler)


	drawKeyboard(2)

	; Tab.UseTab()
	myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "Window"


	; { show GUI
	ogSB := MyGui.AddStatusBar(, "Status Bar")
	myGui.Show()
	; }


	tempCounter := 0
	myGui.drawKeyboard := drawKeyboard
	Return myGui


	drawKeyboard(addedNumer := 0) {
		id := 1
		global keysList := Map()
		col := 1
		loop 4 {
			row := 1
			loop 4 {

				thisButtonX := TabPosition[1] + padding + (row - 1) * (defaultButtonSize + tabContentsSpacingX)
				thisButtonY := TabPosition[2] + tabYpadding + (col - 1) * (defaultButtonSize + tabContentsSpacingY)

				; keysList.Push(
				; 	myGui.Add("Button", "x" thisButtonX " y" thisButtonY " w" defaultButtonSize " h" defaultButtonSize, A_Index "`n" (A_Index + 1 + addedNumer)).OnEvent("Click", OnEventHandler)
				; )
				keysList[id] :=
				myGui.Add("Button", "x" thisButtonX " y" thisButtonY " w" defaultButtonSize " h" defaultButtonSize, A_Index "`n" (A_Index + 1 + addedNumer))

				keysList[id].OnEvent("Click", OnEventHandler)


				row := row + 1
				id := id + 1
			}
			col := col + 1
		}
	}


	OnEventHandler(a, *)
	{
		if !a.HasProp("originalText") {
			a.originalText := a.Text
		}

		a.Text := "Clicked!"

		SetTimer(changeText, -400)		; waits 400 miliseconds
		changeText() {    ; runs after 400 ms
			ToolTip tempCounter++
			a.Text := a.originalText
			a.timerRunning := 0
		}

		ToolTip("Click! This is a sample action.`n", 77, 277)
		SetTimer () => ToolTip(), -3000 ; tooltip timer
	}


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
