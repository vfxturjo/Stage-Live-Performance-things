#SingleInstance force
Persistent
#include Lib\AutoHotInterception.ahk

AHI := AutoHotInterception()
id1 := AHI.GetKeyboardId(0x09DA, 0x2267, 1)
cm1 := AHI.CreateContextManager(id1)
return

#HotIf cm1.IsActive
::aaa::JACKPOT
1::
{
	ToolTip("KEY DOWN EVENT @ " A_TickCount)
	return
}
	
1 up::
{
	ToolTip("KEY UP EVENT @ " A_TickCount)
	return
}
#HotIf

^Esc::
{
	ExitApp
}