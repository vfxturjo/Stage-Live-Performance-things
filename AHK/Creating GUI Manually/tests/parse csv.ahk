#Warn

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


for entry in AllKBDinfo {
    KeyGroup := 1
    KeyKBD := 2
    Xpos := 3
    Ypos := 4
    KeyCodes := 5

    vals := AllKBDinfo[entry]

    continueOrNot := MsgBox("KeyGroup- " vals[KeyGroup] ", KeyKBD-" vals[KeyKBD] ", ActualX- " vals[Xpos] ", ActualY- " vals[Ypos] ", KeyCodes- " vals[KeyCodes] ", ....... continue?", "info", "y/n")
    if (continueOrNot == "No")
        return
}
