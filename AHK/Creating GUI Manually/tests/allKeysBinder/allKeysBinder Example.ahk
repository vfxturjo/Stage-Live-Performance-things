#Include "AllKeysBinder.ahk"

kb := AllKeyBinder(MyFunc)
return

MyFunc(SCcode, codeVK, name, state) {
    ToolTip("Key Code: " SCcode ", VK:" codeVK ", Name: " name ", State: " state)
}

^Esc::
{
    ExitApp()
}
