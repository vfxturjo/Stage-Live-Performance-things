#SingleInstance
#Include Midi2.ahk
#Include helpers.ahk

; #region INIT
; optimizations
A_MaxHotkeysPerInterval := 250
KeyHistory(0), ListLines(0)

OnExit(bye)
bye(*) {
    midi.CloseMidiOuts()
}

midi := AHKMidi()
midi.OpenMidiOut(0)
; #endregion

; #region midi infos
maxKey := 0
channel := 1
velocity := 110
transpose := 0
maxTranspose := 36
SustainPedalON := 0
isPalmMute := 0
BendableNotes := 1
bendRange := 2
numberOfKeys := 0
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
; window.show(), info()
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
KeyCode := 8
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

    ; AllKBDinfo.Push([LineNumber, tempObj])
    kbdUI_AllKBDinfo.Set(LineNumber - 1, tempObj)
}
; #endregion

; #region reading keyBinding files
KeyBindingsFile := IniRead("settings.ini", "general", "currentKeyBindingsFileName", "")
KeyBindingsFolder := IniRead("settings.ini", "general", "keyBindingsFolder", "")
; }

AvailableFunctions := ["midi"]

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
        if (thisKeySetting[1] == "midi") {
            if thisKeySetting.Length != 2 {
                ToolTip("THERE ARE SOME ERROR IN INI FILE, CHECK MIDI PARAMs")
            }
            else {
                ; send midi IF Window is in focus
                HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))

                hotkey GetKeyName('VK' vals[VKCode]), PressMidiNote.bind(A_Index, GetNoteID(thisKeySetting[2]))
                hotkey GetKeyName('VK' vals[VKCode]) ' up', ReleaseMidiNote.bind(A_Index, GetNoteID(thisKeySetting[2]))
            }
        }
    }
}
; #endregion

; #region PressedKeysArray. PressedNotesArray
; pressedKeys (for checking which keyButtons are pressed)
; Stops automatic keystroking when holding
pressedKeysArray := []
pressedKeysArray.Capacity := 200
loop 200 {
    pressedKeysArray.Push(0)
}
; PressedNotes (for checking which MidiNotes are pressend)
; pressedNotesArray := []
; pressedNotesArray.Capacity := 150
; loop 150 {
;     pressedNotesArray.Push(0)
; }
pressedNotesArray := []
; #endregion

; #region MIDI NOTE Press or release
PressMidiNote(keyIndex, note, *) {
    if pressedKeysArray[keyIndex] == 0 { ; to stop the repitition
        pressedKeysArray[keyIndex] := 1

        global transpose
        transposedNote := note + transpose
        ; if (pressedNotesArray[transposedNote] == 0 or SustainPedalON) {
        ; send midi if sustain pedal is ON. cz it wont b turned off eitherway
        midi.MidiOut("N1", channel, note + transpose, velocity)
        ; pressedKeys[key] := 1
        ; pressedNotesArray[transposedNote] := 1

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
    ; if pressedNotesArray[transposedNote] == 1 {
    midi.MidiOut("N0", channel, note + transpose, velocity)
    ; pressedNotesArray[transposedNote] := 0
    global pressedNotesArray := removeItemFromList(pressedNotesArray, transposedNote)
    guiUpdate()
    ; }
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

; #endregion


; #region FUNCS MIDI BENDERS

; ; ; ; ; GOOD BEND BACKUP
; bend(semitones, ret := 0, ms := 10) {
;     ; critical -1
;     ; critical 10
;     limit := 100 / bendRange * semitones
;     step := limit / 20
;     limit *= !ret
;     if semitones > 0 {
;         while pitch() < limit {

;             pitch(step), DllCall('Sleep', 'UInt', ms)
;         }

;     }
;     else
;         while pitch() > limit {

;             pitch(step), DllCall('Sleep', 'UInt', ms)
;         }
;     if ret && pitch()
;         pitch 0
; }


global currentPitch := 0
global PitchBendStepSize := 5
global PitchBendStepSpeed := 5
global PBtarget := 0
global CurrentPitchWanted := 0
global currentPitchTimerID := 0
global pitchBendArray := []

pitchBender := PitchBenderClass(PitchBendStepSize)

bend(PBsemitones, ret := 0, ms := PitchBendStepSpeed) {
    ; to'do: if returning and other pitchBend is held, dont return
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

    if (PBtarget - currentPitch) >= 0 { ; check positive
        global PBstep := PitchBendStepSize
    } else {
        global PBstep := -PitchBendStepSize
    }

    guiUpdate3(PBtarget)

    pitchBender.Stop()
    pitchBender.Start()
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
Home:: {
    Reload
}
PgUp:: {
    ExitApp
}
; #endregion

; #region Bending
AppsKey:: {
    global BendableNotes := !BendableNotes
    info()
}

; Bend Range
ScrollLock:: {
    global bendRange := (bendRange = 2) ? 12 : 2
    info()
}
SC29:: {
    global BendableNotes
    if BendableNotes {
        bend(2)
    }
}
SC29 up:: {
    global BendableNotes
    if BendableNotes {
        bend(2, 1)
    }
}
Tab:: {
    global BendableNotes
    if BendableNotes {
        bend(1)
    }
}
Tab up:: {
    global BendableNotes
    if BendableNotes {
        bend(1, 1)
    } }
CapsLock:: {
    global BendableNotes
    if BendableNotes {
        bend(-1)
    }
}
CapsLock up:: {
    global BendableNotes
    if BendableNotes {
        bend(-1, 1)
    }
}
LShift:: {
    global BendableNotes
    if BendableNotes {
        bend(-2)
    }
}
LShift up:: {
    global BendableNotes
    if BendableNotes {
        bend(-2, 1)
    }
}
; #endregion

; #region Muting or sustain
RAlt:: {
    global SustainPedalON := !SustainPedalON
    info()
}
RCtrl:: {
    mute(1)
    guiUpdate()
}
Space:: {
    mute()
    guiUpdate()
}
; #endregion

; #region Transpose
Left:: {
    global transpose := (Abs(transpose) + 12 > maxTranspose) ? transpose : transpose := transpose - 1
    info()
}
Right:: {
    global transpose := (Abs(transpose) + 12 > maxTranspose) ? transpose : transpose := transpose + 1
    info()
}
Down:: {
    global transpose := (Abs(transpose) + 1 > maxTranspose) ? transpose : transpose := transpose - 12
    info()
}
Up:: {
    global transpose := (Abs(transpose) + 1 > maxTranspose) ? transpose : transpose := transpose + 12
    info()
}
; #endregion

; #region Channel
F3:: {
    mute()
    global channel -= channel > 0
    guiUpdate()
    info()
}
F4:: {
    mute()
    global channel += channel < 15
    guiUpdate()
    info()
}
; #endregion

; #region Velocity
F6:: {
    global velocity -= (velocity > 0) * (10 - 3 * (velocity = 127))
    info()
}
F7:: {
    global velocity += (velocity < 127) * (10 - 3 * (velocity = 120))
    info()
}
; #endregion

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
