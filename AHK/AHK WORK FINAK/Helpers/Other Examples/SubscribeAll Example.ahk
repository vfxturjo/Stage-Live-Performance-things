#SingleInstance force
Persistent
#include Lib\AutoHotInterception.ahk

AHI := AutoHotInterception()

keyboardId := AHI.GetKeyboardId(0x09DA, 0x2267)
AHI.SubscribeKeyboard(keyboardId, true, KeyEvent)

return

KeyEvent(code, state){
	ToolTip("Keyboard Key - Code: " code ", State: " state)
}

^Esc::
{
	ExitApp
}