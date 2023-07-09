myGui := Gui()
myGui.OnEvent("Close", GuiClose)
ogcVarPicture := myGui.Add("Picture", "w400 h200 vVarPicture", "C:\Users\vfxtu\Desktop\1.png")
ogcButtonchangepicture := myGui.Add("Button", "x20 y220", "change picture")
ogcButtonchangepicture.OnEvent("Click", SubButton.Bind("Normal"))
myGui.Show()
return

GuiClose(*)
{ ; V1toV2: Added bracket
    ExitApp()
} ; V1toV2: Added Bracket before label

SubButton(A_GuiEvent, GuiCtrlObj, Info, *)
{ ; V1toV2: Added bracket
    ogcVarPicture.Value := "C:\Users\vfxtu\Desktop\2.png"
    return
} ; V1toV2: Added bracket in the end
