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


CreateGUI()
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


	col := 1
	loop 4 {
		row := 1
		loop 4 {

			thisButtonX := TabPosition[1] + padding + (row - 1) * (defaultButtonSize + tabContentsSpacingX)
			thisButtonY := TabPosition[2] + tabYpadding + (col - 1) * (defaultButtonSize + tabContentsSpacingY)

			myGui.Add("Button", "x" thisButtonX " y" thisButtonY " w" defaultButtonSize " h" defaultButtonSize " cFFFF66", A_Index).OnEvent("Click", OnEventHandler)

			row := row + 1
		}
		col := col + 1
	}

	; Tab.UseTab()
	myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "Window"


	; { show GUI
	ogSB := MyGui.AddStatusBar(, "Status Bar")
	myGui.Show()
	; }


	tempCounter := 0
	Return

	OnEventHandler(a, *)
	{
		if !a.HasProp("originalText") {
			a.originalText := a.Text
		}

		a.Text := "Clicked!"

		SetTimer changeText, -400		; waits 400 miliseconds
		changeText() {    ; runs after 400 ms
			ToolTip tempCounter++
			a.Text := a.originalText
			a.timerRunning := 0
		}

		ToolTip("Click! This is a sample action.`n", 77, 277)
		SetTimer () => ToolTip(), -3000 ; tooltip timer
	}

}
