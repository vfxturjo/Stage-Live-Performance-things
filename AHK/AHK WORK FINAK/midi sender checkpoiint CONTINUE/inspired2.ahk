#SingleInstance
; TraySetIcon 'imageres.dll', 206
KeyHistory(0), ListLines(0)
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
    ; midiPort: 0,
    midiPort: 1,
}

a := {
    midiPort: 1,
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


midiSend(cmd, note, vel := 0) =>
    DllCall('winmm\midiOutShortMsg', 'UInt', midiOut, 'UInt', cmd + a.channel | note << 8 | vel << 16)


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


; TJ FUNCS

PressMiniName(noteName, channel := 1, vel := 120) {
    noteID := noteValue(noteName)
    playMini(noteID, channel, vel)
}

releaseMiniName(noteName, channel := 1, vel := 120) {
    noteID := noteValue(noteName)
    playMini(-noteID, channel, vel)
}

noteValue(note)
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


playMini(note, channel := 0, vel := 120) {
    ; midiSend 0x90, abs(note), (note > 0) * vel
    DllCall('winmm\midiOutShortMsg', 'UInt', midiOut, 'UInt', 0x90 + channel | abs(note) << 8 | ((note > 0) * vel) << 16)
}

;
;
;
;
;
;

PressMiniName("C5")
Sleep(1000)
releaseMiniName("C5")
PressMiniName("C5")
PressMiniName("E5")
PressMiniName("G5")
Sleep(1000)
releaseMiniName("C5")
releaseMiniName("E5")
releaseMiniName("G5")
