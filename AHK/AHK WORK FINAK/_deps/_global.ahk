; #region READING CSV
kbdUI_AllKBDinfo := Map()

KeyGroup := 1
KeyName := 2
iniKeyName := 3
Xpos := 4
Ypos := 5
Xsize := 6
Ysize := 7
SCcode := 8
VKCode := 9

TotalNumOfKeys := 0

Loop read, "csv/KeyboardButtonInfos nikhut.csv"
{
    LineNumber := A_Index
    if (LineNumber == 1)
        continue

    tempObj := []
    Loop parse, A_LoopReadLine, "CSV"
    {
        ; skipping first line
        tempObj.Push(A_LoopField)
        TotalNumOfKeys++
    }

    kbdUI_AllKBDinfo.Set(LineNumber - 1, tempObj)
}
; #endregion


; #region READING SETTINGS
KeyBindingsFile := IniRead("./settings.ini", "general", "currentKeyBindingsFileName", "")
KeyBindingsFolder := IniRead("./settings.ini", "general", "keyBindingsFolder", "")

; #endregion

global AvailableFunctions := ["app", "midi"]
global AvailableAppFunctions := ["exit", "reload"]
global AvailableMidiFunctions := ["note", "bend", "sust", "trans", "chan", "velo", "mute"]
global AvailableSubFunctions := [AvailableAppFunctions, AvailableMidiFunctions]
