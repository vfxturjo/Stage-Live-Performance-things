#SingleInstance
#Include Midi2.ahk
#Include helpers.ahk

OnExit(bye)
bye(*) {
    midi.CloseMidiOuts()
}

midi := AHKMidi()
midi.OpenMidiOut(0)
maxKey := 0
transpose := 0


; { Creating Midi player window
window := gui('+LastFound +AlwaysOnTop -SysMenu')
WinSetTransparent 225
window.SetFont 's11', 'Segoe UI'
guiText := window.add('text', 'w180 h300')
statusBar := window.add('StatusBar')
; window.show(), info()
window.show()
; }


; ; ; ; ; ; CLONING THIS
; layout := '10 1E 2C 11 1F 2D 12 20 2E 13 21 2F 14 22 30 15 23 31 16 24 32 17 25 33 18 26 34 19 27 35 1A 28 36 1B 2B 148 1C'


; { READING CSV
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
; }

; { reading keyBinding files
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
; }


; pressedKeys := Map() ; map based
pressedKeysArray := []
pressedKeysArray.Capacity := 120
loop 120 {
    pressedKeysArray.Push(0)
}

PressMidiNote(key, note, *) {
    global transpose
    ; if (pressedKeys.Has(key) && pressedKeys[key] == 1)
    ;     return
    if (pressedKeysArray[key] == 0) {
        midi.MidiOut("N1", 1, note + transpose, 120)
        ; pressedKeys[key] := 1
        pressedKeysArray[key] := 1
        guiUpdate()
    }

}
ReleaseMidiNote(key, note, *) {
    global transpose
    ; if pressedKeys.Has(key) and (pressedKeys[key] == 1) {
    if pressedKeysArray[key] == 1 {

        midi.MidiOut("N0", 1, note + transpose, 120)
        ; pressedKeys[key] := 0
        pressedKeysArray[key] := 0
        guiUpdate()
    }
}


; 1:: {
;     SendAllNoteOff()
;     SendAllSoundOff()
;     return
; }


; { MIDI RESETTERs
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
; }

;
;
;
;
;;


#HotIf WinActive(wnd)
; Mintainance
Home:: {
    Reload
}
PgUp:: {
    ExitApp
}

; ; ; ; Muting
; RAlt:: a.isSustain := !a.isSustain, info()
; Space up:: (a.isPalmMute) || mute()
; 2:: mute
; 3::
; 4:: mute 0
; 1::

; ; ; ; ; Bending
; AppsKey:: a.isBends := !a.isBends, info()

; ; Bend Range
; ScrollLock:: {
;   (savedKeys.count) || a.bendRange := a.bendRange = 2 ? 12 : 2
; }

; SC29:: (a.isBends) ? bend(2) : octave()
; 1 up::
; SC29 up:: {
;   (a.isBends) ? bend(-2, 1) : 0
; }
; Tab:: {
;   (a.isBends) ? bend(1) : octave(1)
; }
; Tab up:: {
;   (a.isBends) ? bend(-1, 1) : 0
; }
; CapsLock:: {
;   (a.isBends) ? bend(-1) : octave(-1)
; }
; CapsLock up:: {
;   (a.isBends) ? bend(1, 1) : 0
; }
; LShift:: {
;   (a.isBends) ? bend(-2) : 0
; }
; LShift up:: {
;   (a.isBends) ? bend(2, 1) : 0
; }


; Esc:: {
;   bend(-2, , 4), mute(), DllCall('Sleep', 'UInt', 175), pitch(0)
; }

; ; ; ; Transpose
; Left:: {
;   octave -1
; }
; Right:: {
;   octave 1
; }
; Down:: {
;   octave
; }

; F11:: {
;   a.firstNote -= a.firstNote > 24, info()
; }
; F12:: {
;   a.firstNote += a.firstNote < 72, info()
; }


; ; ; ; Channel
; F3:: {
;   mute(), a.channel -= a.channel > 0, info()
; }
; F4:: {
;   mute(), a.channel += a.channel < 15, info()
; }

; ; ; ; Velocity
; F6:: {
;   a.velocity -= (a.velocity > 0) * (10 - 3 * (a.velocity = 127)), info()
; }
; F7:: {
;   a.velocity += (a.velocity < 127) * (10 - 3 * (a.velocity = 120)), info()
; }

#HotIf


guiUpdate() {

    ; showlist() {
    ;     for index, value in pressedKeysArray
    ;         if (value == 1)
    ;             return index "`n"
    ;     return ""
    ;     ; for pressedKeys
    ; }

    ; guiText.value := showlist()
    ; ; todo: make it show the notes

}

; info() {
;     WinSetTitle noteName(a.firstNote) ' (' a.octIndex + 2 '-' a.octIndex + 5 '), vel ' a.velocity ', ch ' a.channel + 1
;     statusBar.SetParts 100, 100
;     statusBar.SetText 'sustain ' (a.isSustain ? '✅' : '❌')
;     statusBar.SetText 'bends ' (a.isBends ? '✅' : '❌'), 2
; }
