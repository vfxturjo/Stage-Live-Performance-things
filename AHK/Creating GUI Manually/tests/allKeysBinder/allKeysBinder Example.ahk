#Include "AllKeysBinder.ahk"

kb := AllKeyBinder(MyFunc)
return

MyFunc(code, name, state) {
    ToolTip("Key Code: " code ", Name: " name ", State: " state)
}

^Esc::
{
    ExitApp()
}
