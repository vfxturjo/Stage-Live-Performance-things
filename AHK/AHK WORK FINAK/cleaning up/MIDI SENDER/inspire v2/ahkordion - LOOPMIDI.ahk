#SingleInstance
; TraySetIcon 'imageres.dll', 206
A_MaxHotkeysPerInterval := 999
KeyHistory(0), ListLines(0)
OnExit bye

layout := '10 1E 2C 11 1F 2D 12 20 2E 13 21 2F 14 22 30 15 23 31 16 24 32 17 25 33 18 26 34 19 27 35 1A 28 36 1B 2B 148 1C'

a := {
  midiPort: 1,
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

window := gui('+LastFound +AlwaysOnTop -SysMenu')
WinSetTransparent 225
window.SetFont 's11', 'Segoe UI'
guiText := window.add('text', 'w180 h300')
statusBar := window.add('StatusBar')
window.OnEvent 'close', (*) => bye()
window.show(), info()

winmm := DllCall('LoadLibrary', 'Str', 'winmm')
DllCall 'winmm\midiOutOpen', 'UInt*', &(midiOut := 0), 'UInt', a.midiPort, 'UPtr', 0, 'UPtr', 0, 'UInt', 0
DllCall 'winmm\midiInOpen', 'UInt*', &(midiIn := 0), 'UInt', 0, 'UInt', WinExist(), 'UInt', 0, 'UInt', 0x10000
DllCall 'winmm\midiInStart', 'UInt', midiIn
OnMessage 0x3C3, midiReceive

HotIf (wnd := 'ahk_class ' WinGetClass(), (*) => WinActive(wnd))
for code in StrSplit(layout, ' ') {
  hotkey GetKeyName('SC' code), press.bind(A_Index)
  hotkey GetKeyName('SC' code) ' up', release.bind(A_Index)
  maxKey++
}

#HotIf WinActive(wnd)
RAlt:: a.isSustain := !a.isSustain, info()
AppsKey:: a.isBends := !a.isBends, info()
Space up:: (a.isPalmMute) || mute()
2:: mute
3::
4:: mute 0
1::
SC29:: (a.isBends) ? bend(2) : octave()
1 up::
SC29 up:: (a.isBends) ? bend(-2, 1) : 0
  Tab:: (a.isBends) ? bend(1) : octave(1)
    Tab up:: (a.isBends) ? bend(-1, 1) : 0
      CapsLock:: (a.isBends) ? bend(-1) : octave(-1)
        CapsLock up:: (a.isBends) ? bend(1, 1) : 0
          LShift:: (a.isBends) ? bend(-2) : 0
            LShift up:: (a.isBends) ? bend(2, 1) : 0
              Esc:: bend(-2, , 4), mute(), DllCall('Sleep', 'UInt', 175), pitch(0)
              ScrollLock:: (savedKeys.count) || a.bendRange := a.bendRange = 2 ? 12 : 2
              Left:: octave -1
              Right:: octave 1
              Down:: octave
              F3:: mute(), a.channel -= a.channel > 0, info()
              F4:: mute(), a.channel += a.channel < 15, info()
              F6:: a.velocity -= (a.velocity > 0) * (10 - 3 * (a.velocity = 127)), info()
              F7:: a.velocity += (a.velocity < 127) * (10 - 3 * (a.velocity = 120)), info()
              F11:: a.firstNote -= a.firstNote > 24, info()
              F12:: a.firstNote += a.firstNote < 72, info()
              #HotIf

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
                guiUpdate
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
                guiUpdate
              }

              pedal() => !a.isBends && (GetKeyState('LShift', 'P') || GetKeyState('Space', 'P'))

              keyToMidi(key, firstNote, octIndex) => --key + firstNote + 12 * octIndex

              mute(noStrum := 1) {
                critical -1
                for m in savedMidi
                  play(-m), noStrum || play(m)
                if noStrum
                  a.anyKey := 0, savedKeys.clear(), savedMidi.clear()
                guiUpdate
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
                WinActive(wnd) && DllCall('winmm\midiOutShortMsg', 'UInt', midiOut, 'UInt', cmd + a.channel | note << 8 | vel << 16)

              midiReceive(hInput, midiMsg, wMsg, *) {
                if WinActive(wnd)
                  return
                cmd := midiMsg & 0xF0
                note := (midiMsg >> 8) & 0xFF
                vel := (midiMsg >> 16) & 0xFF
                if cmd = 0x80 || cmd = 0x90
                  key := ++note - a.firstNote - 12 * a.octIndex,
                    vel && cmd = 0x90 ? press(key) : release(key)
                else if cmd = 0xB0 && note = 0x7B
                  mute
              }

              octave(i := 0) {
                a.octIndex += i > 0 ? a.octIndex < 3 : i < 0 ? -(a.octIndex > -2) : -a.octIndex
                info
              }

              noteName(note, isOctave := 1) {
                static abc := ['C', 'C♯', 'D', 'E♭', 'E', 'F', 'F♯', 'G', 'A♭', 'A', 'B♭', 'B']
                return abc[mod(note, 12) + 1] (isOctave ? note // 12 - 1 : '')
              }

              guiUpdate() {
                static tones := ['n1', 'b2', 'n2', 'b3', 'n3', 'n4', 'b5', 'n5', 'b6', 'n6', 'b7', 'n7']
                row0 := row1 := row2 := chord := ''
                loop maxKey
                  row%mod(A_Index - 1, 3)% .= savedKeys.has(A_Index) ? '⚫' : '⚪'
                if savedKeys.count {
                  notes := []
                  for i, midi in (redundant := map(), savedMidi) {
                    for j, nextMidi in savedMidi
                      if j > i && mod(nextMidi, 12) = mod(midi, 12)
                        redundant[nextMidi] := 1
                    redundant.has(midi) || notes.push(midi)
                  }
                  chordLen := notes.length
                  if chordLen = 1
                    chord := '`n' noteName(notes[1], 0)
                  else
                    loop chordLen {
                      n1 := b2 := n2 := b3 := n3 := n4 := b5 := n5 := b6 := n6 := b7 := n7 := 0
                      for midi in notes
                        %tones[mod(abs(midi - notes[1]), 12) + 1]%++
                      mi3 := b3 && !n3,
                        aug := !b3 && n3 && !n5 && b6,
                        dim := mi3 && b5 && !n5 && !n7,
                        dim7 := dim && n6,
                        hdim := dim && !n6 && b7,
                        no3 := !b3 && !n3 && n5,
                        sus2 := no3 && n2 && !n4,
                        sus4 := no3 && !n2 && n4,
                        is6 := !dim && n6,
                        is7 := !dim && (b7 || n7),
                        is9 := !sus2 && n2,
                        is11 := !sus4 && n4,
                        b9 := b2 ? '(♭9)' : '',
                          n9 := !is7 && is9 ? '(9)' : '',
                            s9 := b3 && n3 ? '(♯9)' : '',
                              n11 := !is7 && is11 ? '(11)' : '',
                                s11 := !dim && b5 ? '(' (n5 ? '♯11' : '♭5') ')' : '',
                                  b13 := !aug && b6 ? '(' (n5 ? '♭13' : '♯5') ')' : '',
                                    root := noteName(notes[1], 0),
                                    type := no3 && chordLen = 2 ? 5 : aug ? '+' : hdim ? 'ø' : dim7 ? '⁰7' : dim ? '⁰' : mi3 ? 'm' : '',
                                      six := !is7 && is6 ? 6 : '',
                                        maj := is7 && !b7 ? 'maj' : '',
                                          dom := is7 ? is6 ? 13 : is11 ? 11 : is9 ? 9 : 7 : '',
                                            sus := sus2 ? 'sus2' : sus4 ? 'sus4' : '',
                                              add := ' ' StrReplace(b9 n9 s9 n11 s11 b13, ')(', ', '),
                                                chord .= '`n' root type six maj dom sus add
                      if A_Index = chordLen
                        break
                      while notes[1] < notes[chordLen]
                        notes[1] += 12
                      notes.push notes.RemoveAt(1)
                    }
                }
                guiText.value := row0 '`n ' row1 '`n   ' row2 chord
              }

              info() {
                WinSetTitle noteName(a.firstNote) ' (' a.octIndex + 2 '-' a.octIndex + 5 '), vel ' a.velocity ', ch ' a.channel + 1
                statusBar.SetParts 100, 100
                statusBar.SetText 'sustain ' (a.isSustain ? '✅' : '❌')
                statusBar.SetText 'bends ' (a.isBends ? '✅' : '❌'), 2
              }

              bye(*) {
                DllCall 'winmm\midiInStop', 'UInt', midiIn
                DllCall 'winmm\midiInClose', 'UInt', midiIn
                DllCall 'winmm\midiOutReset', 'UInt', midiOut
                DllCall 'winmm\midiOutClose', 'UInt', midiOut
                DllCall 'FreeLibrary', 'UPtr', winmm
                ExitApp
              }
