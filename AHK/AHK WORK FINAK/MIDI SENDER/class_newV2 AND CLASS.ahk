midi := MidiOut(0)
midi.volume := 100
n := Array([])
n.Push("")


n.Push(["E4", "F#3", "D2"])
n.Push(["E4", "F3", "D2"])
n.Push("")
n.Push(["E4", "F3", "D2"])

n.Push("")
n.Push(["C4", "F#3", "D2"])
n.Push(["E4", "F3", "D2"])
n.Push("")

n.Push(["G4", "B3", "G3"])
n.Push("")
n.Push("")
n.Push("")

n.Push(["G3", "G2"])
n.Push("")
n.Push("")
n.Push("")

ch := midi.channel[1]
ch.selectInstrument(1)
timer := 150
for k, v in n
{
  sleepMult := 1
  release := 1
  m := Array([])
  for i, s in v
  {
    if (s = "hold")
      release := 0
    else if (regexmatch(s, "release(.+)", &m))
    {
      release := 0
      ch.noteOff(m[1])
    }
  }
  if (release)
    ch.noteOff()
  for i, s in v
  {
    if (regexmatch(s, "sleep(.+)", &m))
      sleepMult := m[1]
    else
      ch.noteOn(s)
  }
  Sleep(timer * sleepMult)
}
pause

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MIDI (Musical Instument Digital Interface)
;; Autor: Bentschi
;; Version: 1.0
;; AutoHotkey version: 1.1
;; Minimum OS: Windows 2000
;;


;* This method can be called before creating a new instance

class MidiOut
{

  ; main
  static volumeMultiplier := 100
  __new(devID := -1)
  {
    ; default values
    pHandle := 0

    ; main
    DllCall("LoadLibrary", "str", "winmm")
    if (DllCall("winmm\midiOutOpen", "ptr*", pHandle, "uint", devID, "ptr", 0, "ptr", 0, "uint", 0) != 0)
      return 0
    this._handle := pHandle
    this.channel := Array([])
    Loop 16
      this.channel.Push(MidiOut.MidiOutChannel(this, A_Index - 1))
    this.defaultChannel := this.channel.minIndex()
  }
  getDeviceList() ;*
  {
    DllCall("LoadLibrary", "str", "winmm")
    count := 0
    list := Array([])
    Loop DllCall("winmm\midiOutGetNumDevs")
    {
      caps := Buffer(84, 0) ; V1toV2: if 'caps' is a UTF-16 string, use 'VarSetStrCapacity(&caps, 84)'
      if (DllCall("winmm\midiOutGetDevCapsW", "ptr", A_Index - 1, "ptr", caps, "uint", 84) != 0)
        continue
      count += 1
      list.Push({ name: StrGet(&caps + 8, 32, "utf-16"), id: A_Index - 1 })
    }
    return (count > 0) ? list : 0
  }
  __get(k)
  {
    if (k = "devID" || k = "deviceID")
      return this.getDeviceID()
    else if (k = "devName" || k = "deviceName")
      return this.getDeviceName()
    else if (k = "volumeL")
      return this.getVolumeLeft()
    else if (k = "volumeR")
      return this.getVolumeRight()
    else if (k = "volume")
      return this.getVolume()
    else if (k = "instrument")
      return this.channel[this.defaultChannel].instrument
  }
  __set(k, v)
  {
    if (k = "volumeL")
      this.setVolumeLeft(v)
    else if (k = "volumeR")
      this.setVolumeRight(v)
    else if (k = "volume")
      this.setVolume(v)
    else if (k = "instrument")
      this.channel[this.defaultChannel].instrument := v
  }
  __delete()
  {
    DllCall("winmm\midiOutClose", "ptr", this._handle)
  }

  getDeviceID()
  {
    if (DllCall("winmm\midiOutGetID", "ptr", this._handle, "uint*", &devID) != 0)
      return
    return devID
  }
  getDeviceName()
  {
    ; original:
    ; VarSetCapacity(caps, 84, 0)
    caps := Buffer(84, 0) ; V1toV2: if 'caps' is a UTF-16 string, use 'VarSetStrCapacity(&caps, 84)'

    if (DllCall("winmm\midiOutGetDevCapsW", "ptr", this.getDeviceID(), "ptr", caps, "uint", 84) != 0)
      return
    return StrGet(&caps + 8, 32, "utf-16")
  }
  ; getVolumeLeft()
  ; {
  ;   if (DllCall("winmm\midiOutGetVolume", "ptr", this._handle, "uint*", vol) != 0)
  ;     return
  ;   return (vol & 0xffff) / 0xffff * this.volumeMultiplier
  ; }
  ; getVolumeRight()
  ; {
  ;   if (DllCall("winmm\midiOutGetVolume", "ptr", this._handle, "uint*", vol) != 0)
  ;     return
  ;   return (vol >> 16) / 0xffff * this.volumeMultiplier
  ; }
  getVolume()
  {

    if (DllCall("winmm\midiOutGetVolume", "ptr", this._handle, "uint*", &vol) != 0)
      return
    return ((vol >> 16) + (vol & 0xffff)) / (2 * 0xffff) * this.volumeMultiplier
  }
  ; setVolumeLeft(vol)
  ; {
  ;   if (DllCall("winmm\midiOutGetVolume", "ptr", this._handle, "uint*", volOld) != 0)
  ;     return
  ;   if (DllCall("winmm\midiOutSetVolume", "ptr", this._handle, "uint", (volOld & 0xffff0000) | round(vol / this.volumeMultiplier * 0xffff)) != 0)
  ;     return
  ;   return 1
  ; }
  ; setVolumeRight(vol)
  ; {
  ;   if (DllCall("winmm\midiOutGetVolume", "ptr", this._handle, "uint*", volOld) != 0)
  ;     return
  ;   if (DllCall("winmm\midiOutSetVolume", "ptr", this._handle, "uint", (volOld & 0xffff) | (round(vol / this.volumeMultiplier * 0xffff) << 16)) != 0)
  ;     return
  ;   return 1
  ; }
  setVolume(vol)
  {
    v := round(vol / this.volumeMultiplier * 0xffff)
    return (DllCall("winmm\midiOutSetVolume", "ptr", this._handle, "uint", (v << 16) | v) != 0) ? "" : 1
  }
  reset()
  {
    return (DllCall("winmm\midiOutReset", "ptr", this._handle) != 0) ? "" : 1
  }


  ;  ; Setter for default channel
  setDefaultChannel(channel)
  {
    result := False
    if (1 <= channel or channel <= 16)
    {
      this.defaultChannel := channel
      result := True
    }
    return result
  }

  noteOn(note, channel := 0, velocity := 127)
  {
    channel := (channel < 1 || channel > 16) ? this.defaultChannel : channel
    this.channel[channel].noteOn(note, velocity)
  }
  ; ; ORIGINAL NOTE ON
  ;  noteOn(note, velocity=127)
  ;  {
  ;    this.channel[this.defaultChannel].noteOn(note, velocity)
  ;  }


  ; since note off velocity is rarely used, I put it after channel
  noteOff(note := "all", channel := 0, velocity := 127)
  {
    channel := (channel < 1 || channel > 16) ? this.defaultChannel : channel
    this.channel[channel].noteOff(note, velocity)
  }
  ; ; ORIGINAL NOTE OFF
  ; noteOff(note = "all", velocity = 127)
  ; {
  ;   this.channel[this.defaultChannel].noteOff(note, velocity)
  ; }

  selectInstrument(instrument := 0)
  {
    this.channel[this.defaultChannel].selectInstrument(instrument)
  }


  _message(msg)
  {
    return (DllCall("winmm\midiOutShortMsg", "ptr", this._handle, "uint", msg) != 0) ? "" : 1
  }

  ; ;   there was no way to send CC messages so I made that:
  ; ; for the MidiOut class
  controlChange(control, value, channel := 0)
  {
    channel := (channel < 1 || channel > 16) ? this.defaultChannel : channel
    this.channel[channel].controlChange(control, value)
  }

  class MidiOutChannel
  {
    __new(midiOut, channelID)
    {
      this._midiOut := midiOut
      this._channelID := channelID
      this._notes := Array([])
      this._instrument := 0
    }
    __get(k)
    {
      if (k = "instrument")
        this._instrument
    }
    __set(k, v)
    {
      if (k = "instrument")
        this.selectInstrument(v)
    }
    noteOn(note, velocity := 127)
    {
      note := this._noteValue(note)
      this._notes[note, velocity] := 1
      return this._midiOut._message(((velocity & 0xff) << 16) | ((note & 0xff) << 8) | ((this._channelID) | 0xf) | 0x90)
    }
    noteOff(note := "all", velocity := 127)
    {
      note := this._noteValue(note)
      if (note = "all")
      {
        for note, velocities in this._notes
        {
          for velocity, i in velocities
            this.noteOff(note, velocity)
        }
        this._notes := Array([])
        return 1
      }
      this._notes[note].remove(velocity)
      return this._midiOut._message(((velocity & 0xff) << 16) | ((note & 0xff) << 8) | ((this._channelID) | 0xf) | 0x80)
    }
    selectInstrument(instrument := 0)
    {
      this._instrument := instrument
      return this._midiOut._message(((instrument & 0xff) << 8) | ((this._channelID) | 0xf) | 0xC0)
    }
    _noteValue(note)
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
    ; ;   there was no way to send CC messages so I made that:
    ; ; for the MidiOutChannel class
    controlChange(control, value)
    {
      return this._midiOut._message(((value & 0xff) << 16) | ((control & 0xff) << 8) | (this._channelID | 0xB0))
    }
  }

}
