myGui := Gui()
ogcbutton := myGui.add("button", "w100")
ogcbutton.OnEvent("Click", button.Bind("Normal"))
ogcbutton := myGui.add("button", "w100")
ogcbutton.OnEvent("Click", button.Bind("Normal"))
ogcbutton := myGui.add("button", "w100")
ogcbutton.OnEvent("Click", button.Bind("Normal"))
myGui.Title := "AHK Rocks"
myGui.show("w200")
OnMessage(0x200, Help)
return

Help(wParam, lParam, Msg) {

    MouseGetPos(, , , &OutputVarControl)

    if (OutputVarControl = "Button1")
        Help := "my button 1"
    else if (OutputVarControl = "Button2")
        Help := "my button 2"
    else if (OutputVarControl = "Button3")
        Help := "my button 3"

    ToolTip(Help)
}
