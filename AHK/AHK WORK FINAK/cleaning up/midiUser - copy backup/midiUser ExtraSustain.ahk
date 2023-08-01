#SingleInstance
#Include Midi2.ahk
#Include helpers.ahk

; #region INIT & optimizations
A_MaxHotkeysPerInterval := 250
KeyHistory(0), ListLines(0)

OnExit(bye)
bye(*) {
    midi.SaveIOSetting("settings.ini")
    midi.CloseMidiOuts()
}

midi := AHKMidi()
midi.LoadIOSetting("settings.ini")
; #endregion

; #region midi infos
channel := 1
velocity := 110
transpose := 0
maxTranspose := 36
SustainPedalON := 0
BendableNotes := 1
bendRange := 2
; #endregion

; #region Creating Midi player window
window := gui('+LastFound +AlwaysOnTop -SysMenu')
WinSetTransparent 225
window.SetFont 's11', 'Segoe UI'
guiText := window.add('text', 'w180 h200')
guiText2 := window.add('text', 'w180 h20')
guiText3 := window.add('text', 'w180 h20')
guiText4 := window.add('text', 'w180 h20')
statusBar := window.add('StatusBar')
window.show()
info()
; #endregion

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

; #region reading keyBinding files
KeyBindingsFile := IniRead("settings.ini", "general", "currentKeyBindingsFileName", "")
KeyBindingsFolder := IniRead("settings.ini", "general", "keyBindingsFolder", "")
; }

AvailableFunctions := ["app", "midi"]
AvailableAppFunctions := ["exit", "reload"]
AvailableMidiFunctions := ["bend", "sust", "trans", "channel", "velocity", "mute"]

for entry in kbdUI_AllKBDinfo {
    vals := kbdUI_AllKBDinfo[entry]

    ; { reading INI for settings
    thisKeySetting := IniRead(KeyBindingsFolder "/" KeyBindingsFile, "keys", vals[iniKeyName], "")
    if thisKeySetting != ""
    {
        thisKeySetting := StrSplit(thisKeySetting, A_Space)

        ; if first part has error
        if (!IsItemInList(thisKeySetting[1], AvailableFunctions)) {
            ToolTip("THERE ARE SOME ERROR IN INI FILE, CHECK FUNCTIONS")
        }
        ; if second part has error
        if (thisKeySetting[1] == "app") {
            if (!IsItemInList(thisKeySetting[2], AvailableAppFunctions)) {
                ToolTip("problem with app hotkeys! SC:" vals[SCcode])
            } else {
                HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
                SCcodeID := Format("{:x}", vals[SCcode])
                hotkey("~*SC" SCcodeID, AppKeyPress.bind(A_Index, thisKeySetting[2]))
            }
        }
        if (thisKeySetting[1] == "midi") {
            if (!IsItemInList(thisKeySetting[2], AvailableMidiFunctions)) {
                ; * data not available in function. Must be a note OR ERROR

                ; send midi IF Window is in focus
                HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
                SCcodeID := Format("{:x}", vals[SCcode])
                ; ; ; VK STYLE KEYMAPPING. WORKS mtmt
                ; try {

                ;     hotkey GetKeyName('VK' vals[VKCode]), PressMidiNote.bind(A_Index, GetNoteID(thisKeySetting[2]))
                ;     hotkey GetKeyName('VK' vals[VKCode]) ' up', ReleaseMidiNote.bind(A_Index, GetNoteID(thisKeySetting[2]))
                ; }
                ; catch {
                ;     MsgBox "problem with VK:" vals[VKCode]
                ; }

                ; ; ; SC Style keymapping
                try {
                    hotkey("~*SC" SCcodeID, PressMidiNote.bind(A_Index, GetNoteID(thisKeySetting[2])))
                    hotkey("~*SC" SCcodeID ' up', ReleaseMidiNote.bind(A_Index, GetNoteID(thisKeySetting[2])))
                }
                catch {
                    MsgBox "problem with SC:" vals[SCcode]
                }
            }
            else
            {
                ; * data matches with AvailableMidiFunctions.
                if (thisKeySetting[2] == "bend") {
                    try {
                        HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
                        SCcodeID := Format("{:x}", vals[SCcode])
                        hotkey("~*SC" SCcodeID, bendPitchPress.bind(A_Index, thisKeySetting[3]))
                        hotkey("~*SC" SCcodeID ' up', bendPitchRelease.bind(A_Index, thisKeySetting[3]))
                    }
                    catch {
                        MsgBox "problem with pitch bend, SC:" vals[SCcode]
                    }

                }
                if (thisKeySetting[2] == "sust") {
                    try {
                        HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
                        SCcodeID := Format("{:x}", vals[SCcode])
                        hotkey("~*SC" SCcodeID, SustainPedalPress.bind(A_Index, thisKeySetting[3]))
                        hotkey("~*SC" SCcodeID ' up', SustainPedalRelease.bind(A_Index, thisKeySetting[3]))
                    }
                    catch {
                        MsgBox "problem with sustain pedal, SC:" vals[SCcode]
                    }

                }
                if (thisKeySetting[2] == "trans") {
                    try {
                        HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
                        SCcodeID := Format("{:x}", vals[SCcode])
                        hotkey("~*SC" SCcodeID, transposeKeyPress.bind(A_Index, thisKeySetting[3]))
                        hotkey("~*SC" SCcodeID ' up', transposeKeyRelease.bind(A_Index, thisKeySetting[3]))
                    }
                    catch {
                        MsgBox "problem with Transpose, SC:" vals[SCcode]
                    }

                }
                if (thisKeySetting[2] == "channel") {
                    try {
                        HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
                        SCcodeID := Format("{:x}", vals[SCcode])
                        hotkey("~*SC" SCcodeID, ChannelKeyPress.bind(A_Index, thisKeySetting[3]))
                        hotkey("~*SC" SCcodeID ' up', ChannelKeyRelease.bind(A_Index, thisKeySetting[3]))
                    }
                    catch {
                        MsgBox "problem with Transpose, SC:" vals[SCcode]
                    }
                }
                if (thisKeySetting[2] == "velocity") {
                    try {
                        HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
                        SCcodeID := Format("{:x}", vals[SCcode])
                        hotkey("~*SC" SCcodeID, VelocityKeyPress.bind(A_Index, thisKeySetting[3]))
                        hotkey("~*SC" SCcodeID ' up', VelocityKeyRelease.bind(A_Index, thisKeySetting[3]))
                    }
                    catch {
                        MsgBox "problem with Transpose, SC:" vals[SCcode]
                    }

                }
                if (thisKeySetting[2] == "mute") {
                    try {
                        HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
                        SCcodeID := Format("{:x}", vals[SCcode])
                        hotkey("~*SC" SCcodeID, MuteKeyPress.bind(A_Index, thisKeySetting[3]))
                        hotkey("~*SC" SCcodeID ' up', MuteKeyRelease.bind(A_Index, thisKeySetting[3]))
                    }
                    catch {
                        MsgBox "problem with Transpose, SC:" vals[SCcode]
                    }

                }
            }
        }
    }
}

; #endregion

; #region Transpose PRESS AND RELEASE

AppKeyPress(keyIndex, function, *) {
    if (function == "exit") {
        ExitApp
    }
    if (function == "reload") {
        Reload
    }
}
; #endregion


; #region PressedKeysArray. PressedNotesArray
pressedKeysArray := []
pressedKeysArray.Capacity := 200
loop 200 {
    pressedKeysArray.Push(0)
}

pressedNotesArray := []
; #endregion

; #region MIDI NOTE Press or release
PressMidiNote(keyIndex, note, *) {
    if pressedKeysArray[keyIndex] == 0 { ; to stop the repitition
        pressedKeysArray[keyIndex] := 1

        global transpose
        transposedNote := note + transpose

        global SustainPedalON
        if SustainPedalON {
            midi.MidiOut("N0", channel, transposedNote, velocity)
        }
        midi.MidiOut("N1", channel, transposedNote, velocity)

        global pressedNotesArray := removeItemFromList(pressedNotesArray, transposedNote)
        pressedNotesArray.Push(transposedNote)
        guiUpdate()
    }
}

ReleaseMidiNote(keyIndex, note, *) {
    pressedKeysArray[keyIndex] := 0 ; to stop the repitition
    if SustainPedalON == 1 {    ; dont stop the note
        return
    }

    global transpose
    transposedNote := note + transpose
    midi.MidiOut("N0", channel, transposedNote, velocity)

    global pressedNotesArray := removeItemFromList(pressedNotesArray, transposedNote)
    guiUpdate()
}
; #endregion

; #region pressPitchBend
bendPitchPress(keyIndex, bendAmount, *) {
    global BendableNotes
    if BendableNotes {
        bend(bendAmount)
    }
    guiUpdate4()
}

bendPitchRelease(keyIndex, bendAmount, *) {
    global BendableNotes
    if BendableNotes {
        bend(bendAmount, 1)
    }
    guiUpdate4()
}
; #endregion

; #region SUSTAIN AND MUTE PRESS AND RELEASE
global sustainPedalKeyPressed := 0
SustainPedalPress(keyIndex, Press_or_Toggle, *) {
    global sustainPedalKeyPressed
    if (sustainPedalKeyPressed == 1) {
        return
    }
    sustainPedalKeyPressed := 1

    if Press_or_Toggle == "press" {
        global SustainPedalON := !SustainPedalON
    }
    else if (Press_or_Toggle == "toggle") { ; if toggle, just change once when pressed.
        ; dont change back when released
        global SustainPedalON := !SustainPedalON
    }

    info()
}

SustainPedalRelease(keyIndex, Press_or_Toggle, *) {
    global sustainPedalKeyPressed := 0

    if Press_or_Toggle == "press" {
        global SustainPedalON := !SustainPedalON
    }

    info()
}

global MuteKeyPressed := 0
MuteKeyPress(keyIndex, MuteOnPress_or_Release, *) {
    global MuteKeyPressed
    if (MuteKeyPressed == 1) {
        return
    }
    MuteKeyPressed := 1

    if MuteOnPress_or_Release == "press" {
        mute()
        guiUpdate()
    }
}

MuteKeyRelease(keyIndex, MuteOnPress_or_Release, *) {
    global MuteKeyPressed := 0

    if MuteOnPress_or_Release == "release" {
        mute()
        guiUpdate()
    }
}
; #endregion

; #region Transpose PRESS AND RELEASE
global transposeKeyPressed := 0
transposeKeyPress(keyIndex, transposeAmount, *) {
    global transposeKeyPressed
    if (transposeKeyPressed == 1) {
        return
    }
    transposeKeyPressed := 1

    global transpose := (Abs(transpose) + transposeAmount > maxTranspose) ? transpose : transpose := transpose - transposeAmount

    info()
}

transposeKeyRelease(keyIndex, transposeAmount, *) {
    global transposeKeyPressed := 0
}
; #endregion

; #region Channel PRESS AND RELEASE
global ChannelKeyPressed := 0
ChannelKeyPress(keyIndex, ChannelPlusOrMinus, *) {
    global ChannelKeyPressed
    if (ChannelKeyPressed == 1) {
        return
    }
    ChannelKeyPressed := 1

    mute()
    if ChannelPlusOrMinus > 0 {
        global channel += channel < 15
    } else {
        global channel -= channel > 0
    }
    info()
}

ChannelKeyRelease(keyIndex, transposeAmount, *) {
    global ChannelKeyPressed := 0
}
; #endregion

; #region Velocity PRESS AND RELEASE
global VelocityKeyPressed := 0
VelocityKeyPress(keyIndex, VelocityPlusOrMinus, *) {
    global VelocityKeyPressed
    if (VelocityKeyPressed == 1) {
        return
    }
    VelocityKeyPressed := 1

    if VelocityPlusOrMinus > 0 {
        global velocity += (velocity < 127) * (10 - 3 * (velocity = 120))
    } else {
        global velocity -= (velocity > 0) * (10 - 3 * (velocity = 127))
    }

    info()
}

VelocityKeyRelease(keyIndex, transposeAmount, *) {
    global VelocityKeyPressed := 0
}
; #endregion


; #region FUNCS MIDI RESETTERs
SendAllNoteOff(ch := 1)
{
    dwMidi := (176 + ch) + (123 << 8) + (0 << 16)
    midi.MidiOutRawData(dwMidi)
}

SendAllSoundOff(ch := 1)
{
    dwMidi := (176 + ch) + (120 << 8) + (0 << 16)
    midi.MidiOutRawData(dwMidi)
}

SendResetAllController(ch := 1)
{
    dwMidi := (176 + ch) + (121 << 8) + (0 << 16)
    midi.MidiOutRawData(dwMidi)
}

; sends NoteOff to those which have noteOn in array
mute(force := 0) {  ; Previous name: reset everything by array
    if force == 0 {
        for key, value in pressedNotesArray {
            midi.MidiOut("N0", channel, value, 120)
        }
    }
    else {   ; forcefully goes though array and sends NoteOff to all
        for key, value in pressedNotesArray {
            midi.MidiOut("N0", channel, value, 120)
        }
        SendAllNoteOff()
        SendAllSoundOff()
        SendResetAllController()
    }
    global pressedNotesArray := []
}
; #endregion

; #region FUNCS MIDI PITCH BEND

global currentPitch := 0
global PitchBendStepSize := 5
global PitchBendStepSpeed := 5
global PBtarget := 0
global CurrentPitchWanted := 0
global currentPitchTimerID := 0
global pitchBendArray := []

pitchBender := PitchBenderClass(PitchBendStepSize)

bend(PBsemitones, ret := 0, ms := PitchBendStepSpeed) {
    global CurrentPitchWanted
    global pitchBendArray
    if !ret {
        if CurrentPitchWanted == PBsemitones {
            guiText3.Text := " x"
            return
        }
        pitchBendArray.Push(PBsemitones)
        guiUpdate4()
    } else {
        pitchBendArray := removeItemFromList(pitchBendArray, PBsemitones)
        guiUpdate4()
    }

    ; showToolTipforTime(pitchBendArray.Length)
    global CurrentPitchWanted := pitchBendArray.Length > 0 ? pitchBendArray[pitchBendArray.Length] : 0

    global currentPitch
    global PBtarget := Integer(100 / bendRange * CurrentPitchWanted)

    PBtargetDistance := PBtarget - currentPitch
    if (PBtargetDistance) >= 0 { ; check positive
        global PBstep := Abs(PBtargetDistance) > 10 * PitchBendStepSize ? PitchBendStepSize * 2 : PitchBendStepSize
    } else {
        global PBstep := Abs(PBtargetDistance) > 10 * PitchBendStepSize ? -PitchBendStepSize * 2 : -PitchBendStepSize
    }

    guiUpdate3(PBtarget)
    pitchBender.pitchBendTowardsNewTarget()
}

; #endregion

;
;
;
;
;

; #region HOTKEYS MANUAL
#HotIf WinActive(wnd)
; #region Mintainance
^Home:: {
    Reload
}
^End:: {
    ExitApp
}
; #endregion

; ; #region Bending
; AppsKey:: {
;     global BendableNotes := !BendableNotes
;     info()
; }

; ; Bend Range
; ScrollLock:: {
;     global bendRange := (bendRange = 2) ? 12 : 2
;     info()
; }
; ; SC29:: {
; ;     global BendableNotes
; ;     if BendableNotes {
; ;         bend(2)
; ;     }
; ; }
; SC29 up:: {
;     global BendableNotes
;     if BendableNotes {
;         bend(2, 1)
;     }
; }
; Tab:: {
;     global BendableNotes
;     if BendableNotes {
;         bend(1)
;     }
; }
; Tab up:: {
;     global BendableNotes
;     if BendableNotes {
;         bend(1, 1)
;     } }
; CapsLock:: {
;     global BendableNotes
;     if BendableNotes {
;         bend(-1)
;     }
; }
; CapsLock up:: {
;     global BendableNotes
;     if BendableNotes {
;         bend(-1, 1)
;     }
; }
; LShift:: {
;     global BendableNotes
;     if BendableNotes {
;         bend(-2)
;     }
; }
; LShift up:: {
;     global BendableNotes
;     if BendableNotes {
;         bend(-2, 1)
;     }
; }
; ; #endregion

; ; #region Muting or sustain
; RAlt:: {
;     global SustainPedalON := !SustainPedalON
;     info()
; }
; RCtrl:: {
;     mute(1)
;     guiUpdate()
; }
; Space:: {
;     mute()
;     guiUpdate()
; }
; ; #endregion

; ; #region Transpose
; Left:: {
;     global transpose := (Abs(transpose) + 12 > maxTranspose) ? transpose : transpose := transpose - 1
;     info()
; }
; Right:: {
;     global transpose := (Abs(transpose) + 12 > maxTranspose) ? transpose : transpose := transpose + 1
;     info()
; }
; Down:: {
;     global transpose := (Abs(transpose) + 1 > maxTranspose) ? transpose : transpose := transpose - 12
;     info()
; }
; Up:: {
;     global transpose := (Abs(transpose) + 1 > maxTranspose) ? transpose : transpose := transpose + 12
;     info()
; }
; ; #endregion

; ; #region Channel
; F3:: {
;     mute()
;     global channel -= channel > 0
;     guiUpdate()
;     info()
; }
; F4:: {
;     mute()
;     global channel += channel < 15
;     guiUpdate()
;     info()
; }
; ; #endregion

; ; #region Velocity
; F6:: {
;     global velocity -= (velocity > 0) * (10 - 3 * (velocity = 127))
;     info()
; }
; F7:: {
;     global velocity += (velocity < 127) * (10 - 3 * (velocity = 120))
;     info()
; }
; ; #endregion

#HotIf
; #endregion

; #region GUI UPDATE
guiUpdate() {
    guiText.value := showListAsString(pressedNotesArray)
}

guiUpdate2(text) {
    guiText2.Value := text
}
guiUpdate3(text) {
    guiText3.Value := text
}
guiUpdate4() {
    guiText4.Value := showListAsString(pitchBendArray)
}
; #endregion

; #region GUI INFO UPDATE
info() {
    WinSetTitle("trans: " transpose " vel: " velocity ', ch: ' channel)

    statusBar.SetParts 70, 70, 70
    statusBar.SetText('sustain ' (SustainPedalON ? '✅' : '❌'))
    statusBar.SetText('bends ' (BendableNotes ? '✅' : '❌'), 2)
    statusBar.SetText('Rng ' bendRange, 3)
}
; #endregion
