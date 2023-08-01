#Requires Autohotkey v2
#Include _deps\helpers.ahk

myGui := Gui()
Radio_PlayMode := myGui.Add("Radio", "w120 h23", "Play Mode")
Radio_PlayMode.OnEvent("Click", modeChangeHandler)
Radio_SettingsMode := myGui.Add("Radio", "w120 h23", "Settings Mode")
Radio_SettingsMode.OnEvent("Click", modeChangeHandler)

myGui.Add("Button", "w80 h23", "Reload App").OnEvent("Click", (*) => (Reload()))

myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window"
myGui.Show("w620 h420")
Return

modeChangeHandler(*)
{
    DetectHiddenWindows("On")
    if Radio_PlayMode.Value == 1 {
        try {
            WinClose("GuiTry5 nikhut.ahk")
            WinClose("midiUser counterSpeed.ahk")
        } catch Error as e {
            showToolTipforTime(e.Message, 3000)
        }
        Run("midiUser counterSpeed.ahk")
    }
    if Radio_SettingsMode.Value == 1 {
        try {
            WinClose("GuiTry5 nikhut.ahk")
            WinClose("midiUser counterSpeed.ahk")
        } catch Error as e {
            showToolTipforTime(e.Message, 3000)
        }
        Run("GuiTry5 nikhut.ahk")
    }
    ToolTip("Click! This is a sample action.`n"
        . "Active GUI element values include:`n"
        . "Radio_1 => " Radio_PlayMode.Value "`n"
        . "Radio_2 => " Radio_SettingsMode.Value "`n", 77, 277)
    SetTimer () => ToolTip(), -3000 ; tooltip timer
}
