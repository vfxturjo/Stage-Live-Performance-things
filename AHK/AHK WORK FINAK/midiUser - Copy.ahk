#SingleInstance
#Include Midi2.ahk

midi := AHKMidi()
maxKey := 0

; window := gui('+LastFound +AlwaysOnTop -SysMenu')
; WinSetTransparent 225
; window.SetFont 's11', 'Segoe UI'
; guiText := window.add('text', 'w180 h300')
; statusBar := window.add('StatusBar')
; window.OnEvent 'close', (*) => bye()
; window.show(), info()


; ; ; ; ; CLONING THIS
; layout := '10 1E 2C 11 1F 2D 12 20 2E 13 21 2F 14 22 30 15 23 31 16 24 32 17 25 33 18 26 34 19 27 35 1A 28 36 1B 2B 148 1C'


; ; HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
; for code in StrSplit(layout, ' ') {
;     Hotkey GetKeyName("SC" code), tester.Bind(A_Index)
;     hotkey GetKeyName('SC' code), press2.bind(A_Index)
;     hotkey GetKeyName('SC' code) ' up', release2.bind(A_Index)

;     maxKey++
; }


press2(key, *) {
    MsgBox key

    midi.MidiOut("N1", 1, 60, 120)

    ; midi.MidiOutRawData(createMidiRawData(60))
    ; press(key)
    ; guiUpdate()
}
release2(key, *) {
    midi.MidiOut("N0", 1, 60, 120)
    ; midi.MidiOutRawData(createMidiRawData(60))
    ; release(key)
    ; guiUpdate()
}

1:: {
    SendAllNoteOff()
    SendAllSoundOff()
    return
}


; MIDI RESETTERs
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
;
;
;
;


; ; ; how Midi Raw data is created
; midiSend 0x90, abs(note), (note > 0) * vel

; midiSend(cmd, note, vel := 0) =>
;     DllCall('winmm\midiOutShortMsg', 'UInt', midiOutdeviceID, 'UInt', cmd + a.channel | note << 8 | vel << 16)

createMidiRawData(note, vel := 120) {
    return 0x90 + 1 | note << 8 | vel << 16
}


;
;
;
;
;;

; #HotIf WinActive(wnd)
; RAlt:: a.isSustain := !a.isSustain, info()
; AppsKey:: a.isBends := !a.isBends, info()
; Space up:: (a.isPalmMute) || mute()
; 2:: mute
; 3::
; 4:: mute 0
; 1::
; SC29:: (a.isBends) ? bend(2) : octave()
; 1 up::
; SC29 up:: {
;     (a.isBends) ? bend(-2, 1) : 0
; }

; Tab:: {
;     (a.isBends) ? bend(1) : octave(1)
; }

; Tab up:: {
;     (a.isBends) ? bend(-1, 1) : 0
; }
; CapsLock:: {
;     (a.isBends) ? bend(-1) : octave(-1)
; }
; CapsLock up:: {
;     (a.isBends) ? bend(1, 1) : 0
; }
; LShift:: {
;     (a.isBends) ? bend(-2) : 0
; }
; LShift up:: {
;     (a.isBends) ? bend(2, 1) : 0
; }
; Esc:: {
;     bend(-2, , 4), mute(), DllCall('Sleep', 'UInt', 175), pitch(0)
; }
; ScrollLock:: {
;     (savedKeys.count) || a.bendRange := a.bendRange = 2 ? 12 : 2
; }
; Left:: {
;     octave -1
; }
; Right:: {
;     octave 1
; }
; Down:: {
;     octave
; }
; F3:: {
;     mute(), a.channel -= a.channel > 0, info()
; }
; F4:: {
;     mute(), a.channel += a.channel < 15, info()
; }
; F6:: {
;     a.velocity -= (a.velocity > 0) * (10 - 3 * (a.velocity = 127)), info()
; }
; F7:: {
;     a.velocity += (a.velocity < 127) * (10 - 3 * (a.velocity = 120)), info()
; }
; F11:: {
;     a.firstNote -= a.firstNote > 24, info()
; }
; F12:: {
;     a.firstNote += a.firstNote < 72, info()
; }
Home:: {
    Reload
}
PgUp:: {
    ExitApp
}
; #HotIf


; guiUpdate() {
;     static tones := ['n1', 'b2', 'n2', 'b3', 'n3', 'n4', 'b5', 'n5', 'b6', 'n6', 'b7', 'n7']
;     row0 := row1 := row2 := chord := ''
;     loop maxKey
;         row%mod(A_Index - 1, 3)% .= savedKeys.has(A_Index) ? '⚫' : '⚪'
;     if savedKeys.count {
;         notes := []
;         for i, midi in (redundant := map(), savedMidi) {
;             for j, nextMidi in savedMidi
;                 if j > i && mod(nextMidi, 12) = mod(midi, 12)
;                     redundant[nextMidi] := 1
;             redundant.has(midi) || notes.push(midi)
;         }
;         chordLen := notes.length
;         if chordLen = 1
;             chord := '`n' noteName(notes[1], 0)
;         else
;             loop chordLen {
;                 n1 := b2 := n2 := b3 := n3 := n4 := b5 := n5 := b6 := n6 := b7 := n7 := 0
;                 for midi in notes
;                     %tones[mod(abs(midi - notes[1]), 12) + 1]%++
;                 mi3 := b3 && !n3,
;                     aug := !b3 && n3 && !n5 && b6,
;                     dim := mi3 && b5 && !n5 && !n7,
;                     dim7 := dim && n6,
;                     hdim := dim && !n6 && b7,
;                     no3 := !b3 && !n3 && n5,
;                     sus2 := no3 && n2 && !n4,
;                     sus4 := no3 && !n2 && n4,
;                     is6 := !dim && n6,
;                     is7 := !dim && (b7 || n7),
;                     is9 := !sus2 && n2,
;                     is11 := !sus4 && n4,
;                     b9 := b2 ? '(♭9)' : '',
;                     n9 := !is7 && is9 ? '(9)' : '',
;                         s9 := b3 && n3 ? '(♯9)' : '',
;                             n11 := !is7 && is11 ? '(11)' : '',
;                                 s11 := !dim && b5 ? '(' (n5 ? '♯11' : '♭5') ')' : '',
;                                     b13 := !aug && b6 ? '(' (n5 ? '♭13' : '♯5') ')' : '',
;                                         root := noteName(notes[1], 0),
;                                         type := no3 && chordLen = 2 ? 5 : aug ? '+' : hdim ? 'ø' : dim7 ? '⁰7' : dim ? '⁰' : mi3 ? 'm' : '',
;                                             six := !is7 && is6 ? 6 : '',
;                                                 maj := is7 && !b7 ? 'maj' : '',
;                                                     dom := is7 ? is6 ? 13 : is11 ? 11 : is9 ? 9 : 7 : '',
;                                                         sus := sus2 ? 'sus2' : sus4 ? 'sus4' : '',
;                                                             add := ' ' StrReplace(b9 n9 s9 n11 s11 b13, ')(', ', '),
;                                                                 chord .= '`n' root type six maj dom sus add
;                 if A_Index = chordLen
;                     break
;                 while notes[1] < notes[chordLen]
;                     notes[1] += 12
;                 notes.push notes.RemoveAt(1)
;             }
;     }
;     guiText.value := row0 '`n ' row1 '`n   ' row2 chord
; }

; info() {
;     WinSetTitle noteName(a.firstNote) ' (' a.octIndex + 2 '-' a.octIndex + 5 '), vel ' a.velocity ', ch ' a.channel + 1
;     statusBar.SetParts 100, 100
;     statusBar.SetText 'sustain ' (a.isSustain ? '✅' : '❌')
;     statusBar.SetText 'bends ' (a.isBends ? '✅' : '❌'), 2
; }
