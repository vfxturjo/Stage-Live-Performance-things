; #region array, list, string, util funcs
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

showListAsString(listArray) {
    str := ""
    For Index, Value In listArray
        str .= " " . Value

    return str
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

removeItemFromList(ListArray, item) {
    output := []
    for k, v in ListArray
    {
        if (v != item) {
            output.Push(v)
        }
    }
    return output
}

getClampedValue(wantedValue, clampLow, ClampHigh) {
    return (wantedValue < clampLow) ? clampLow : (wantedValue > ClampHigh) ? ClampHigh : wantedValue
}
; #endregion

; #region GUI, tooltips, prompts
showToolTipforTime(text, time := 3000) {
    ToolTip text
    SetTimer () => ToolTip(), -time
    return
}


askForValidInput2(insideText, windowName, regexMatchStr, wrongTollTipText := "Check your input!", width := 200, height := 100) {
    while 1 {
        global AvailableFunctions
        global AvailableSubFunctions

        ; askingGUI := Gui("+AlwaysOnTop")
        askingGUI := Gui("+AlwaysOnTop")

        function_treeview := askingGUI.Add("TreeView", "w160 h160 Section")
        a := function_treeview.add("app", , "Expand")
        b := function_treeview.add("reload", a)
        c := function_treeview.add("restart", a)


        ; function_treeview.OnEvent("ItemSelect", (*) => (MsgBox(function_treeview.Value)))
        function_treeview.OnEvent("Click", (*) => (MsgBox(
            function_treeview.GetText(function_treeview.GetParent(function_treeview.GetSelection()))
            " "
            function_treeview.GetText(function_treeview.GetSelection()))))


        ; Notes_treeview := askingGUI.Add("TreeView", "w160 h160 ")
        ; for id, value in ['C', 'C♯', 'D', 'E♭', 'E', 'F', 'F♯', 'G', 'A♭', 'A', 'B♭', 'B'] {
        ;     b := Notes_treeview.add(value)
        ; }
        notes_ARRAY := [
            ['C', 'C♯'],
            ['D', 'D#'],
            ['E'],
            ['F', 'F♯'],
            ['G', 'G#'],
            ['A', 'A#'],
            ['B']
        ]

        for i, element in notes_ARRAY {
            positioning := ""
            positioning := "xs Section"

            ; create a new section beside
            if i == 1 {
                positioning := "ys Section"
            }
            for j, element1 in element {
                askingGUI.Add("Radio", " w50 h30 " positioning, element1).OnEvent("Click", note_Radio_click)
                ; a := askingGUI.Add("Radio")
                ; a.

                positioning := "ys"
            }
        }

        note_Radio_click(guiCtrlObj, info, *) {
            MsgBox(guiCtrlObj.Text)
            ; previewText.Text :=

        }

        askingGUI.Add("Button", "w50 h30 -Section", "OK").OnEvent("Click", (*) => (askingGUI.Destroy()))


        previewText := askingGUI.Add("Text", "xm w250 h20 +0x200 +Border", " preview settings here.")
        NamedCtrlContents := askingGUI.Submit()

        askingGUI.Show()
        return 0
    }
}
; ; didnt use it because involves lots of keystrokes. easier with treeview
; askForValidInput2(insideText, windowName, regexMatchStr, wrongTollTipText := "Check your input!", width := 200, height := 100) {
;     while 1 {
;         global AvailableFunctions
;         global AvailableSubFunctions

;         askingGUI := Gui("+AlwaysOnTop")
;         FunctionDropDown := askingGUI.Add("DropDownList", " w120", AvailableFunctions)
;         SubFunctionDropDown := askingGUI.Add("DropDownList", "w120", ["choose Function First"])

;         FunctionDropDown.OnEvent("Change", (*) => (
;             SubFunctionDropDown.Delete()
;             SubFunctionDropDown.Add(AvailableSubFunctions[FunctionDropDown.Value])
;             SubFunctionDropDown.Redraw()))

;         askingGUI.Show()
;         return 0


;     }
; }

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
; #endregion

; #region all keys binder
class AllKeyBinder {
    __New(callback, pfx := "~*") {
        keys := Map()
        this.Callback := callback
        Loop 512 {
            i := A_Index
            code := Format("{:x}", i)
            n := GetKeyName("sc" code)
            if (!n || keys.HasProp(n))
                continue

            keys[n] := code

            fn := this.KeyEvent.Bind(this, i, n, 1)
            Hotkey(pfx "SC" code, fn, "On")

            fn := this.KeyEvent.Bind(this, i, n, 0)
            Hotkey(pfx "SC" code " up", fn, "On")
        }
    }

    KeyEvent(code, name, state, *) {
        this.Callback.Call(code, name, state)
    }
}
; #endregion

; #region Midi Notes
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
; #endregion
