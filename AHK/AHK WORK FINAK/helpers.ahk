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

showToolTipforTime(text, time := 3000) {
    ToolTip text
    SetTimer () => ToolTip(), -time
    return
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

class PitchBenderClass {
    __New(PitchBendSpeed) {
        this.PitchBendSpeed := PitchBendSpeed
        this.count := 0
        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "Tick")
    }
    Start() {
        SetTimer this.timer, this.PitchBendSpeed
    }
    Stop() {
        SetTimer this.timer, 0
    }
    pitchBendTowardsNewTarget() {
        this.Stop()
        this.Start()
    }
    ; In this example, the timer calls this method:
    Tick() {
        global currentPitch
        global PBtarget

        if Abs(currentPitch) > 100 {
            ; global currentPitch := 0
            ; global PBtarget := 0
            ; ToolTip "PROBLEM"
            this.Stop()
            return
            ; SetTimer(, 0)
        }

        if currentPitch == PBtarget {
            ; SetTimer(, 0)
            this.Stop()
            return
        }

        ; if (PBtarget - currentPitch) >= 0 { ; check positive
        ;     step := PitchBendSpeed
        ; } else {
        ;     step := -PitchBendSpeed
        ; }
        global PBstep
        pitch(PBstep)
        guiUpdate2(PBtarget " " currentPitch)
    }
}

pitch(value := '') {
    static saved := 0
    ; MsgBox value
    if IsNumber(value) {
        saved := !value ? 0 : round(saved + value, 2)
        saved := (saved < -100) ? -100 : (saved > 100) ? 100 : saved
        new := round((100 + saved) / 200 * 0x4000)
        new -= new = 0x4000

        ; rawData := (0xE0 + channel - 1 | new & 0x7F << 8 | ((new >> 7) & 0x7F) << 16)
        ; midi.MidiOutRawData(rawData)

        midi.MidiOutRawData(0xE0 + channel - 1 | new & 0x7F << 8 | ((new >> 7) & 0x7F) << 16)
        global currentPitch += value
    }
}


;
;
;
;

;
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
