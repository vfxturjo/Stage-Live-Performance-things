ArrCSL(vText)
{
    return StrSplit(vText, ",")
}

CSL(vText)
{
    if !IsObject(vText)
        return StrSplit(vText, ",")
    oArray := vText
    Loop (oArray.Length()) {
        vOutput .= (A_Index = 1 ? "" : ",") oArray[A_Index]
    }
    return vOutput
}

IsItemInList(item, list, del := ",")
{
    If IsObject(list) {
        for k, v in list
            if (v = item)
                return true
        return false
    } else Return !!InStr(del list del, del item del)
}

indexOfItemInList(item, list)
{
    id := 1
    If IsObject(list) {
        for k, v in list
            if (v = item) {

                return id
            }
            else {
                id++
            }
        return false
    }
}

askForValidInput(insideText, windowName, regexMatchStr, wrongTollTipText := "Check your input!", width := 200, height := 100) {
    while 1 {

        IB := InputBox("insideText", windowName, "w" width " h" height)
        if (IB.Result = "Cancel") {
            return -1
        }
        else
        {
            if (!RegExMatch(IB.Value, "([a-zA-Z]#\d|[a-zA-Z]\d)")) {
                ToolTip wrongTollTipText
                SetTimer () => ToolTip(), -3000
            }
            else {
                return IB.Value
            }
        }
    }
}


; ; ; ; tried to bind all keys but couldnt
; loop TotalNumOfKeys {
; 	try {
; 		Hotkey("SC" Format("{:03}", kbdUI_AllKBDinfo[A_Index][KeyCode]), respondToKeyInGui)  ; Alt+W
; 	}
; 	catch Error as e {
; 		ErrorList.Push(e)
; 	}
; }

noteName(note, isOctave := 1) {
    static abc := ['C', 'C♯', 'D', 'E♭', 'E', 'F', 'F♯', 'G', 'A♭', 'A', 'B♭', 'B']
    return abc[mod(note, 12) + 1] (isOctave ? note // 12 - 1 : '')
}

GetNoteID(note)
{
    ; Extract note name and octave using regex
    match := Array([])
    regexMatch(note, "(\D+)(\d+)", &match)
    ; note_name := match[1] ,,,,, octave := match[2]
    return 12 * match[2] + Map(
        "C", 0,
        "C#", 1,
        "D", 2,
        "D#", 3,
        "E", 4,
        "F", 5,
        "F#", 6,
        "G", 7,
        "G#", 8,
        "A", 9,
        "A#", 10,
        "B", 11
    )[match[1]]
}
