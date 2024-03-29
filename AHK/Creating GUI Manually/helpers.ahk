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
