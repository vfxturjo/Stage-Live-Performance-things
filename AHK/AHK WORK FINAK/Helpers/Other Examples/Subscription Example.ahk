#SingleInstance force
Persistent
#include Lib\AutoHotInterception.ahk

AHI := AutoHotInterception()

keyboardId := AHI.GetKeyboardId(0x09DA, 0x2267)
AHI.SubscribeKey(keyboardId, GetKeySC("1"), true, KeyEvent)
return

KeyEvent(state){
	ToolTip("State: " state)
}

^Esc::
{
	ExitApp
}