#SingleInstance
; TraySetIcon 'imageres.dll', 206
A_MaxHotkeysPerInterval := 999
KeyHistory(0), ListLines(0)
OnExit bye

bye(*) {
    ; DllCall 'winmm\midiInStop', 'UInt', midiIn
    ; DllCall 'winmm\midiInClose', 'UInt', midiIn
    DllCall('winmm\midiOutReset', 'UInt', midiOut)
    DllCall('winmm\midiOutClose', 'UInt', midiOut)
    DllCall('FreeLibrary', 'UPtr', winmm)
    ExitApp
}


settings := {
    midiPort: 0,
    ; midiPort: 1,
}

a := {
    midiPort: 0,
    channel: 0,
    isSustain: 0,
    isBends: 1,
    velocity: 110,
    lowVelocity: 90,
    firstNote: 40,        ; - for easy offset changing
    octIndex: 0,          ; - for easy octave changing
    bendRange: 2,
    anyKey: 0,
    isPalmMute: 0
}

pressedKeys := map()
savedKeys := map()
savedMidi := map()
maxKey := 0

; TJ LOGIC
pressedNotes := map()


; ==== DLL WORKS
; ; load library
winmm := DllCall('LoadLibrary', 'Str', 'winmm')
; ; open Midi Out device
DllCall('winmm\midiOutOpen', 'UInt*', &(midiOut := 0), 'UInt', settings.midiPort, 'UPtr', 0, 'UPtr', 0, 'UInt', 0)
; ; ignoring Midi In
; DllCall( 'winmm\midiInOpen', 'UInt*', &(midiIn := 0), 'UInt', 0, 'UInt', WinExist(), 'UInt', 0, 'UInt', 0x10000)
; DllCall('winmm\midiInStart', 'UInt', midiIn)
; OnMessage(0x3C3, midiReceive)


press(k, *) {
    if pressedKeys.has(k) && pressedKeys[k]
        return
    pressedKeys[k] := 1
    (a.isSustain && !a.anyKey && !pedal()) && mute()
    a.anyKey++
    noteInfo := [a.firstNote, a.octIndex]
    m := keyToMidi(k, noteInfo*)
    savedMidi.has(m) && play(-m)
    play m
    savedKeys[k] := noteInfo
    savedMidi[m] := m
    ; guiUpdate
}

release(k, *) {
    pressedKeys[k] := 0
    if !(a.anyKey && savedKeys.has(k))
        return
    a.anyKey--
    if a.isSustain || pedal()
        return
    m := keyToMidi(k, savedKeys[k]*)
    play -m
    savedKeys.delete k
    savedMidi.has(m) && savedMidi.delete(m)
    ; guiUpdate
}

pedal() => !a.isBends && (GetKeyState('LShift', 'P') || GetKeyState('Space', 'P'))

keyToMidi(key, firstNote, octIndex) => --key + firstNote + 12 * octIndex

mute(noStrum := 1) {
    critical -1
    for m in savedMidi
        play(-m), noStrum || play(m)
    if noStrum
        a.anyKey := 0, savedKeys.clear(), savedMidi.clear()
    ; guiUpdate
}

bend(semitones, ret := 0, ms := 2) {
    critical -1
    semi := abs(semitones)
    limit := 100 / (A_ThisHotkey = 'Esc' ? 2 : a.bendRange) * semitones
    step := limit / 20
    limit *= !ret
    if semitones > 0 {
        while pitch() < limit
            pitch(step), DllCall('Sleep', 'UInt', ms)
    }
    else
        while pitch() > limit
            pitch(step), DllCall('Sleep', 'UInt', ms)
    if ret && pitch()
        pitch 0
}

pitch(value := '') {
    static saved := 0
    if IsNumber(value)
        saved := !value ? 0 : round(saved + value, 2),
            saved := saved < -100 ? -100 : saved > 100 ? 100 : saved,
                new := round((100 + saved) / 200 * 0x4000),
                    new -= new = 0x4000,
                    midiSend(0xE0, new & 0x7F, (new >> 7) & 0x7F)
    return saved
}

play(note) {
    muted := a.isBends && GetKeyState('Space', 'P')
    vel := GetKeyState('BS') ? 127 : muted ? a.lowVelocity : a.velocity
    midiSend 0x90, abs(note), (note > 0) * vel
    a.isPalmMute := muted && vel = a.lowVelocity
}

midiSend(cmd, note, vel := 0) =>
    ; WinActive(wnd) &&
    DllCall('winmm\midiOutShortMsg', 'UInt', midiOut, 'UInt', cmd + a.channel | note << 8 | vel << 16)

; midiReceive(hInput, midiMsg, wMsg, *) {
;     ; if WinActive(wnd)
;     ;     return
;     cmd := midiMsg & 0xF0
;     note := (midiMsg >> 8) & 0xFF
;     vel := (midiMsg >> 16) & 0xFF
;     if cmd = 0x80 || cmd = 0x90
;         key := ++note - a.firstNote - 12 * a.octIndex,
;             vel && cmd = 0x90 ? press(key) : release(key)
;     else if cmd = 0xB0 && note = 0x7B
;         mute
; }

octave(i := 0) {
    a.octIndex += i > 0 ? a.octIndex < 3 : i < 0 ? -(a.octIndex > -2) : -a.octIndex
    ; info
}

noteName(note, isOctave := 1) {
    static abc := ['C', 'C♯', 'D', 'E♭', 'E', 'F', 'F♯', 'G', 'A♭', 'A', 'B♭', 'B']
    return abc[mod(note, 12) + 1] (isOctave ? note // 12 - 1 : '')
}


; press("C5")
; Sleep(1000)
; release("C5")
; press("C5")
; press("E5")
; press("G5")
; Sleep(1000)
; release("C5")
; release("E5")
; release("G5")

press(67)
sleep(1000)
release(67)


; =========================== EXTRA COLLECTED FUNCTIONS
; ; ; ; RESET HELPER
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
