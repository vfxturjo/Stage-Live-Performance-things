#SingleInstance
; TraySetIcon 'imageres.dll', 206
A_MaxHotkeysPerInterval := 999
KeyHistory(0), ListLines(0)
OnExit bye

layout := '10 1E 2C 11 1F 2D 12 20 2E 13 21 2F 14 22 30 15 23 31 16 24 32 17 25 33 18 26 34 19 27 35 1A 28 36 1B 2B 148 1C'

a := {
    midiPort: 0,
    channel: 0,
    isSustain: 0,
    isBends: 1,
    velocity: 110,
    lowVelocity: 90,
    firstNote: 40,
    octIndex: 0,
    bendRange: 2,
    anyKey: 0,
    isPalmMute: 0
}


pressedKeys := map()
savedKeys := map()
savedMidi := map()
maxKey := 0


winmm := DllCall('LoadLibrary', 'Str', 'winmm')
DllCall 'winmm\midiOutOpen', 'UInt*', &(midiOut := 0), 'UInt', a.midiPort, 'UPtr', 0, 'UPtr', 0, 'UInt', 0
DllCall 'winmm\midiInOpen', 'UInt*', &(midiIn := 0), 'UInt', 0, 'UInt', WinExist(), 'UInt', 0, 'UInt', 0x10000
DllCall 'winmm\midiInStart', 'UInt', midiIn
OnMessage 0x3C3, midiReceive


; HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
; for code in StrSplit(layout, ' ') {
;     hotkey GetKeyName('SC' code), press.bind(A_Index)
;     hotkey GetKeyName('SC' code) ' up', release.bind(A_Index)
;     maxKey++
; }


press(k, *) {
    if pressedKeys.has(k) && pressedKeys[k]
        return
    pressedKeys[k] := 1
    a.anyKey++
    noteInfo := [a.firstNote, a.octIndex]
    m := keyToMidi(k, noteInfo*)
    savedMidi.has(m) && play(-m)
    play m
    savedKeys[k] := noteInfo
    savedMidi[m] := m
}

release(k, *) {
    pressedKeys[k] := 0
    if !(a.anyKey && savedKeys.has(k))
        return
    a.anyKey--
    m := keyToMidi(k, savedKeys[k]*)
    play -m
    savedKeys.delete k
    savedMidi.has(m) && savedMidi.delete(m)
}

keyToMidi(key, firstNote, octIndex) => --key + firstNote + 12 * octIndex


play(note) {
    muted := a.isBends && GetKeyState('Space', 'P')
    vel := GetKeyState('BS') ? 127 : muted ? a.lowVelocity : a.velocity
    midiSend 0x90, abs(note), (note > 0) * vel
    a.isPalmMute := muted && vel = a.lowVelocity
}

midiSend(cmd, note, vel := 0) =>
    DllCall('winmm\midiOutShortMsg', 'UInt', midiOut, 'UInt', cmd + a.channel | note << 8 | vel << 16)

midiReceive(hInput, midiMsg, wMsg, *) {
    cmd := midiMsg & 0xF0
    note := (midiMsg >> 8) & 0xFF
    vel := (midiMsg >> 16) & 0xFF
    if cmd = 0x80 || cmd = 0x90
        key := ++note - a.firstNote - 12 * a.octIndex,
            vel && cmd = 0x90 ? press(key) : release(key)
    else if cmd = 0xB0 && note = 0x7B
        mute
}

mute(noStrum := 1) {
    critical -1
    for m in savedMidi
        play(-m), noStrum || play(m)
    if noStrum
        a.anyKey := 0, savedKeys.clear(), savedMidi.clear()
}

noteName(note, isOctave := 1) {
    static abc := ['C', 'C♯', 'D', 'E♭', 'E', 'F', 'F♯', 'G', 'A♭', 'A', 'B♭', 'B']
    return abc[mod(note, 12) + 1] (isOctave ? note // 12 - 1 : '')
}


bye(*) {
    DllCall 'winmm\midiInStop', 'UInt', midiIn
    DllCall 'winmm\midiInClose', 'UInt', midiIn
    DllCall 'winmm\midiOutReset', 'UInt', midiOut
    DllCall 'winmm\midiOutClose', 'UInt', midiOut
    DllCall 'FreeLibrary', 'UPtr', winmm
    ExitApp
}


;
;
;
;
;


press(60)
Sleep(1000)
ExitApp
