﻿;*************************************************
;*      MIDI INPUT DETECTION 
;              PARSE FUNCTION
;*************************************************
/* 
  Midi messages are made up of several sections
  Statusbyte, midi channel, data1, data2 - they are all combined into one midi message
  https://www.nyu.edu/classes/bello/FMT_files/9_MIDI_code.pdf
*/

MidiMsgDetect(hInput, midiMsg, wMsg) ; Midi input section in calls this function each time a midi message is received. Then the midi message is broken up into parts for manipulation.  See http://www.midi.org/techspecs/midimessages.php (decimal values).
 {
    global statusbyte, chan, note, cc, data1, data2, stb, pitchb ; Make these vars gobal to be used in other functions
    ; ===============; Extract Variables by extracting from midi message
    statusbyte :=  midiMsg & 0xFF                ; Extract statusbyte = what type of midi message and what midi channel
    chan          := (statusbyte & 0x0f) + 1      ; WHAT MIDI CHANNEL IS THE MESSAGE ON? EXTRACT FROM STATUSBYTE
    data1         := (midiMsg >> 8) & 0xFF     ; THIS IS DATA1 VALUE = NOTE NUMBER OR CC NUMBER
    data2         := (midiMsg >> 16) & 0xFF   ; DATA2 VALUE IS NOTE VELEOCITY OR CC VALUE
    pitchb        := (data2 << 7) | data1          ;(midiMsg >> 8) & 0x7F7F  masking to extract the pbs  
  ; =============== assign stb variable for display only ; ===============
  if (statusbyte >= 176 && statusbyte <= 191)   ; Is message a CC
    stb := "CC"                                        ; if so then set stb to CC - only used with the midi monitor
  if (statusbyte >= 144 && statusbyte <= 159)   ; Is message a Note On
    stb := "NoteOn"                               ; Set gui var
  if (statusbyte >= 128 && statusbyte <= 143)   ; Is message a Note Off?
    stb := "NoteOff"                              ; set gui to NoteOff
  if (statusbyte >= 192 && statusbyte <= 208)   ;Program Change
    stb := "PC"
  if (statusbyte >= 224 && statusbyte <= 239)   ; Is message a Pitch Bend
    stb := "PitchB"                                 ; Set gui to pb

  MidiInDisplay(stb, statusbyte, chan, data1, data2) ; ===============Show midi input on midi monitor display ; =============== 
  MidiRules()                                                        ; =============== run midirules label to organize 
  } ; =============== ; end of MidiMsgDetect funciton
Return

;*************************************************
;*    SHOW MIDI INPUT ON GUI MONITOR
;*************************************************

MidiInDisplay(stb, statusbyte, chan, data1, data2)   ; update the midimonitor gui - see below
{
oGui14 := Gui()
oGui14.default()
oGui14.ListView("In1")                                             ; see the first listview midi in monitor
  LV.Add("", stb, statusbyte, chan, data1, data2)  ; Setting up the columns for gui
  LV.ModifyCol(1, "center")
  LV.ModifyCol(2, "center")
  LV.ModifyCol(3, "center")
  LV.ModifyCol(4, "center")
  LV.ModifyCol(5, "center")
  If (LV.GetCount() > 10)
    {
      LV.Delete(1)
    }
}
return

;*************************************************
;*    SHOW MIDI OUTPUT ON GUI MONITOR
;*************************************************

MidiOutDisplay(stb, statusbyte, chan, data1, data2) ;  update the midimonitor gui
{
oGui14.default()
oGui14.ListView("Out1") ; see the second listview midi out monitor
  LV.Add("", stb, statusbyte, chan, data1, data2)
  LV.ModifyCol(1, "center")
  LV.ModifyCol(2, "center")
  LV.ModifyCol(3, "center")
  LV.ModifyCol(4, "center")
  LV.ModifyCol(5, "center")
  If (LV.GetCount() > 10)
    {
      LV.Delete(1)
    }
}
return

;*************************************************
;*      MIDI MONITOR GUI CODE - creates the monitor window
;*************************************************

midiMon: ; midi monitor gui with listviews
oGui14.destroy()
oGui14.default()
oGui14.add("text", "x80 y5", "Midi Input") ; %TheChoice%
  ogcDropDownListMidiInPort := oGui14.Add("DropDownList", "x40 y20 w140 Choose" . TheChoice . " vMidiInPort  altsubmit", [MiList])
  ogcDropDownListMidiInPort.OnEvent("Change", DoneInChange.Bind("Change"))  ; (
oGui14.add("text", "x305 y5", "Midi Ouput") ; %TheChoice2%
  ogcDropDownListMidiOutPort := oGui14.Add("DropDownList", "x270 y20 w140  Choose" . TheChoice2 . " vMidiOutPort  altsubmit", [MoList])
  ogcDropDownListMidiOutPort.OnEvent("Change", DoneOutChange.Bind("Change"))
ogcListViewIn1 := oGui14.Add("ListView", "x5 r11 w220 Backgroundblack caqua Count10 vIn1", ["EventType", "StatB", "Ch", "data1", "data2", ""])
ogcListViewOut1 := oGui14.Add("ListView", "x+5 r11 w220 Backgroundblack cyellow Count10 vOut1", ["EventType", "StatB", "Ch", "data1", "data2", ""])
oGui14. add("Button", "x10 w205", "Done - Reload script.")
.OnEvent("Change", Set_Done.Bind("Change"))
  oGui14. add("Button", "xp+205 w205", "Cancel")
  .OnEvent("Change", Cancel.Bind("Change"))
oGui14.Title := "MidiMonitor"
oGui14.Show("autosize xcenter y5")

Return

;*************************************************
;*              MIDI SET GUI  - midi setup
;*************************************************

; =============== MIDI INPUT SELECTION ; ==============
MidiSet()                                                                    ; midi port selection gui
{ ; V1toV2: Added bracket
  oGui6 := Gui()
  oGui6. Destroy()
  oGui2 := Gui()
  oGui2. Destroy()
  oGui3 := Gui()
  oGui3. Destroy()
  oGui4 := Gui()
  oGui4. Destroy()
  oGui4.Opt("+LastFound +AlwaysOnTop   +Caption +ToolWindow")        ;-SysMenu
  oGui4. Font("s12")
  oGui4. add("text", "x10 y10 w300 cmaroon", "Select Midi Ports.")       ; Text title
  oGui4. Font("s8")
  oGui4. Add("Text", "x10 y+10 w175 Center", "Midi In Port")                 ;Just text label
  oGui4. font("s8")
  ; =============== MIDI INPUT SELECTION ; ===============
  oGui4. Add("ListBox", "x10 w200 h100  Choose" . TheChoice . " vMidiInPort  AltSubmit", [MiList])
  ogcListBoxMidiInPort.OnEvent("Change", DoneInChange.Bind("Change")) ; --- midi in listing of ports
    ;Gui,  Add, DropDownList, x10 w200 h120 Choose%TheChoice% vMidiInPort gDoneInChange altsubmit, %MiList%  ; ( you may prefer this style, may need tweak)

  ; =============== MIDI OUTPUT SELECTION ; ===============
  oGui4. Add("TEXT", "x220 y40 w175 Center", "Midi Out Port")               ; gDoneOutChange
  ; midi outlist box
  oGui4. Add("ListBox", "x220 y62 w200 h100 Choose" . TheChoice2 . " vMidiOutPort  AltSubmit", [MoList])
  ogcListBoxMidiOutPort.OnEvent("Change", DoneOutChange.Bind("Change")) ; --- midi out listing
  ;Gui,  Add, DropDownList, x220 y97 w200 h120 Choose%TheChoice2% vMidiOutPort gDoneOutChange altsubmit , %MoList%
  oGui4. add("Button", "x10 w205", "Done - Reload script.")
  .OnEvent("Change", Set_Done.Bind("Change"))
  oGui4. add("Button", "xp+205 w205", "Cancel")
  .OnEvent("Change", Cancel.Bind("Change"))
  oGui4. show(, version . " Midi Port Selection")                                ; main window title and command to show it.

Return

; =============== gui done change stuff - see label in both gui listbox line ; ===============
  ;44444444444444444444444444 NEED TO EDIT THIS TO REFLECT CHANGES IN GENMCE PRIOR TO SEND OUT
} ; V1toV2: Added bracket before function
DoneInChange(A_GuiEvent, GuiCtrlObj, Info, *)                                   ; Run this when midi input port has changed 
{ ; V1toV2: Added bracket
  oGui4.Opt("+lastfound")
  oSaved := oGui4.Submit("0")
  MidiInPort := oSaved.MidiInPort
  MidiOutPort := oSaved.MidiOutPort
  ersion := oSaved.ersion
  oGui4.Flash()
  oGui4. Submit("NoHide")
  oGui4. Flash()
  If %MidiInPort%
      UDPort:= MidiInPort - 1, MidiInDevice:= UDPort ; probably a much better way do this, I took this from JimF's qwmidi without out editing much.... it does work same with doneoutchange below.
  ogcUDPort.Value := MidiIndevice
  WriteIni()
  ;MsgBox, 32, , midi in device = %MidiInDevice%`nmidiinport = %MidiInPort%`nport = %port%`ndevice= %device% `n UDPort = %UDport% ; ===============UNCOMMENT FOR TESTING IF NEEDED
Return
} ; V1toV2: Added Bracket before label

DoneOutChange(A_GuiEvent, GuiCtrlObj, Info, *)
{ ; V1toV2: Added bracket
  oGui4.Opt("+lastfound")
  oSaved := oGui4.Submit("0")
  MidiInPort := oSaved.MidiInPort
  MidiOutPort := oSaved.MidiOutPort
  ersion := oSaved.ersion
  oGui4.Flash()
  oGui4. Submit("NoHide")
  oGui4. Flash()
  If %MidiOutPort%
      UDPort2:= MidiOutPort - 1 , MidiOutDevice:= UDPort2
  ogcUDPort2.Value := MidiOutdevice
  WriteIni()
  ;Gui, Destroy
Return
} ; V1toV2: Added Bracket before label

Set_Done(A_GuiEvent, GuiCtrlObj, Info, *)                                                                    ; aka reload program, called from midi selection gui
{ ; V1toV2: Added bracket
  oGui3. Destroy()
  oGui4. Destroy()
   Sleep(100)
  Reload()
Return
} ; V1toV2: Added Bracket before label

Cancel(A_GuiEvent, GuiCtrlObj, Info, *)
{ ; V1toV2: Added bracket
  oGui4.Destroy()
  oGui2. Destroy()
  oGui3. Destroy()
  oGui4. Destroy()
  oGui5 := Gui()
  oGui5. Destroy()
Return
} ; V1toV2: Added Bracket before label

ResetAll:                                                                 ; program reset if needed by user
  msgResult := MsgBox("This will delete ALL settings, and restart this program!", version " - Reset All?", 33)
  if (msgResult = "OK")
    {
      FileDelete(version ".ini")                             ; delete the ini file to reset ports, probably a better way to do this ...
      Reload()                                                            ; restart the app.
    }
  if (msgResult = "Cancel")
Return

GuiClose:                                                               ; on x exit app
  #SuspendExempt                                                ; allow Exit to work Paused. 
   msgResult := MsgBox("Exit " version " " ver "?", "Exit " version, 4) ; 
  if (msgResult = "No")
      Return
  Else   if (msgResult = "Yes")
      midiOutClose(h_midiout)
  oGui6. Destroy()
  oGui2. Destroy()
  oGui3. Destroy()
  oGui4. Destroy()
  oGui5. Destroy()
  oGui7 := Gui()
  oGui7. destroy()
Sleep(100)
  ;winclose, Midi_in_2 ;close the midi in 2 ahk file
ExitApp()

;*************************************************
;*          GET PORTS LIST AND PARSE
;*************************************************

MidiPortRefresh:                                    ; get the list of ports

 MIlist := MidiInsList(NumPorts)        ; Get midi inputs list 
	Loop Parse, MIlist, "|"
		{
		}
	TheChoice := MidiInDevice + 1

MOlist := MidiOutsList(NumPorts2)   ; Get midi outputs list
   Loop Parse, MOlist, "|"
		{
		}
	TheChoice2 := MidiOutDevice + 1

return

;*************************************************
;*          CHECK .INI file for previous configuration
;*************************************************
;-----------------------------------------------------------------

ReadIni()                                         ; Read .ini file to load port settings - also set up the tray Menu
  {
    tray:= A_TrayMenu
    tray.add("MidiSet")           ; set midi ports tray item
    tray.add("ResetAll")          ; DELETE THE .INI FILE - a new config needs to be set up
    tray.add("MidiMon")        ; Menu item for the midi monitor
    global MidiInDevice, MidiOutDevice, version ; version var is set at the beginning.
    if FileExist(version ".ini")
      {
        MidiInDevice := IniRead(version ".ini", "Settings", "MidiInDevice", MidiInDevice)            ; read the midi In port from ini file
        MidiOutDevice := IniRead(version ".ini", "Settings", "MidiOutDevice", MidiOutDevice)   ; read the midi out port from ini file
      }
    Else                                                                                    ; no ini exists and this is either the first run or reset settings.
      {
        msgResult := MsgBox("Select midi ports?", "No ini file found", 1)      ; Prompt user to select midi ports 
        if (msgResult = "Cancel")
          ExitApp()
        if (msgResult = "yes")
          midiset()     ; run the midi setup routine
      }
  } ; endof readini

;*************************************************
;*   WRITE TO INI FILE FUNCTION  + UPDATE INI WHENEVER SAVED PARAMETERS CHANGE
;*************************************************

WriteIni()                                                                  ; Write selections to .ini file 
  {
    global MidiInDevice, MidiOutDevice, version
      if !FileExist(version ".ini")                                   ; if no .ini 
        FileAppend(, version ".ini")                              ; make  .ini with the following entries.
    IniWrite(MidiInDevice, version ".ini", "Settings", "MidiInDevice")
    IniWrite(MidiOutDevice, version ".ini", "Settings", "MidiOutDevice")
  }

;*************************************************
;*                 PORT TESTING
;*************************************************

port_test(numports,numports2)                             ; confirm selected ports exist ; CLEAN THIS UP STILL 
  {
    global midiInDevice, midiOutDevice, midiok    ; Set varibles to golobal 
    
    ;; =============== In port selection test based on numports ; ===============
    if !(MidiInDevice >= 0 && MidiInDevice <= numports)
      {
        MidiIn := 0 ; this var is just to show if there is an error - set if the ports are valid = 1, invalid = 0
            ;MsgBox, 0, , midi in port Error ; (this is left only for testing)
        If (MidiInDevice = "")                                      ; if there is no midi in device 
            MidiInerr := "Midi In Port EMPTY."                ; set this var = error message
            ;MsgBox, 0, , midi in port EMPTY
        If (midiInDevice > %numports%)                  ; if greater than the number of ports on the system.
            MidiInnerr := "Midi In Port Invalid."              ; set this error message
            ;MsgBox, 0, , midi in port out of range
      }
    Else
      {
        MidiIn := 1                                                     ; setting var to non-error state or valid
      }
    ; =============== out port selection test based on numports2 ; ===============
    if !(MidiOutDevice >= 0 && MidiOutDevice <= numports2)
      {
        MidiOut := 0                                                    ; set var to 0 as Error state.
        If (MidiOutDevice = "")                                  ; if blank
            MidiOuterr := "Midi Out Port EMPTY."         ; set this error message
            ;MsgBox, 0, , midi o port EMPTY - THIS LINE IS JUST FOR TESTING
        If (midiOutDevice > %numports2%)             ; if greater than number of availble ports  
            MidiOuterr := "Midi Out Port Out Invalid."  ; set this error message   
            ;MsgBox, 0, , midi out port out of range - THIS LINE IS JUST FOR TESTING
      }
    Else
      {
        MidiOut := 1                                                    ; set var to 1 as valid state.
      }
      ; =============== test to see if ports valid, if either invalid load the gui to select ; ===============
      ;midicheck(MCUin,MCUout)
    If (%MidiIn% = 0) Or (%MidiOut% = 0)
      {
        msgResult := MsgBox(MidiInerr "`n" MidiOuterr "`n`nLaunch Midi Port Selection!", "Midi Port Error!", 49)
        if (msgResult = "Cancel")
          ExitApp()
        midiok := "0"                                                      ; Not sure if this is really needed now....
        MidiSet()                                               ;Gui, show Midi Port Selection
      }
    Else
      {
        midiok := "1"
        Return                                                              ; DO NOTHING - PERHAPS DO THE NOT TEST INSTEAD ABOVE.
      }
  }
Return
; =============== end of port testing ; ===============

;*************************************************
;*          MIDI OUTPUT - UNDER THE HOOD
;*************************************************

; =============== Midi output detection ; ===============
MidiOut:                                                                 ; label to load new settings from midi out menu item
  OpenCloseMidiAPI()
  h_midiout := midiOutOpen(MidiOutDevice)   ; OUTPUT PORT 1 SEE BELOW FOR PORT 2
return


MidiOutsList(&NumPorts)                        ; works with unicode now
  { ; Returns a "|"-separated list of midi output devices
    local List, MidiOutCaps, PortName, result, midisize
  (1)? offsetWordStr := 64: offsetWordStr := 32
  midisize := offsetWordStr + 18
  MidiOutCaps := Buffer(midisize, 0) ; V1toV2: if 'MidiOutCaps' is a UTF-16 string, use 'VarSetStrCapacity(&MidiOutCaps, midisize)'
    VarSetStrCapacity(&PortName, offsetWordStr)                             ; PortNameSize 32 ; V1toV2: if 'PortName' is NOT a UTF-16 string, use 'PortName := Buffer(offsetWordStr)'

    NumPorts := DllCall("winmm.dll\midiOutGetNumDevs")   ; midi output devices on system, First device ID = 0

    Loop NumPorts
      {
        result := DllCall("winmm.dll\midiOutGetDevCaps", "Uint", A_Index - 1, "Ptr", MidiOutCaps, "Uint", midisize)

        If (result) {
            List .= "|-Error-"
            Continue
          }
    PortName := StrGet(&MidiOutCaps + 8, offsetWordStr)
        List .= "|" PortName
      }
    Return SubStr(List, 2)
  }

; ===============-midiOut from TomB and Lazslo and JimF --------------------------------
;THATS THE END OF MY STUFF (JimF) THE REST ID WHAT LASZLo AND PAXOPHONE WERE USING ALREADY
;AHK FUNCTIONS FOR MIDI OUTPUT - calling winmm.dll
;http://msdn.microsoft.com/library/default.asp?url=/library/en-us/multimed/htm/_win32_multimedia_functions.asp
;Derived from Midi.ahk dated 29 August 2008 - streaming support removed - (JimF)

OpenCloseMidiAPI() {  ; at the beginning to load, at the end to unload winmm.dll
    static hModule
    If hModule
        DllCall("FreeLibrary", "UInt", hModule), hModule := ""
    If (0 = hModule := DllCall("LoadLibrary", "Str", "winmm.dll")) {
        MsgBox("Cannot load libray winmm.dll")
        Exit()
      }
  }

; ===============FUNCTIONS FOR SENDING SHORT MESSAGES ; ===============

midiOutOpen(uDeviceID := 0) { ; Open midi port for sending individual midi messages --> handle
    strh_midiout := "0000"

    result := DllCall("winmm.dll\midiOutOpen", "UInt", strh_midiout, "UInt", uDeviceID, "UInt", 0, "UInt", 0, "UInt", 0, "UInt")
    If (result or ErrorLevel) {
        MsgBox("There was an Error opening the midi port.`nError code " result "`nErrorLevel = " ErrorLevel)
        Return -1
      }
    Return UInt@(&strh_midiout)
  }
;*****************************************************************
;   ALL MIDI SENT TO THE OUTPUT MIDI PORT - CALLS THIS FUNCTION
;*****************************************************************

midiOutShortMsg(h_midiout, MidiStatus,  Param1, Param2) { ;Channel,
    ;h_midiout: handle to midi output device returned by midiOutOpen
    ;EventType, Channel combined -> MidiStatus byte: http://www.harmony-central.com/MIDI/Doc/table1.html
    ;Param3 should be 0 for PChange, ChanAT, or Wheel
    ;Wheel events: entire Wheel value in Param2 - the function splits it into two bytes
/*
    If (EventType = "NoteOn" OR EventType = "N1")
        MidiStatus := 143 + Channel
    Else If (EventType = "NoteOff" OR EventType = "N0")
        MidiStatus := 127 + Channel
    Else If (EventType = "CC")
        MidiStatus := 175 + Channel
    Else If (EventType = "PolyAT"  OR EventType = "PA")
        MidiStatus := 159 + Channel
    Else If (EventType = "ChanAT"  OR EventType = "AT")
        MidiStatus := 207 + Channel
    Else If (EventType = "PChange" OR EventType = "PC")
        MidiStatus := 191 + Channel
    Else If (EventType = "Wheel"   OR EventType = "W") {
        MidiStatus := 223 + Channel
        Param2 := Param1 >> 8      ; MSB of wheel value
        Param1 := Param1 & 0x00FF  ; strip MSB
      }
*/
    result := DllCall("winmm.dll\midiOutShortMsg", "UInt", h_midiout, "UInt", MidiStatus|(Param1<<8)|(Param2<<16), "UInt")
    If (result or ErrorLevel)  {
        MsgBox("There was an Error Sending the midi event: (" result ", " ErrorLevel ")")
        Return -1
      }
  }     ; ends midi out function

midiOutClose(h_midiout) {  ; Close MidiOutput
    Loop 9 {
        result := DllCall("winmm.dll\midiOutClose", "UInt", h_midiout)
        If !(result or ErrorLevel)
            Return
        Sleep(250)
      }
    MsgBox("Error in closing the midi output port. There may still be midi events being Processed.")
    Return -1
  }

;UTILITY FUNCTIONS
MidiOutGetNumDevs() { ; Get number of midi output devices on system, first device has an ID of 0
    Return DllCall("winmm.dll\midiOutGetNumDevs")
  }

MidiOutNameGet(uDeviceID := 0) { ; Get name of a midiOut device for a given ID

    ;MIDIOUTCAPS struct
    ;    WORD      wMid;
    ;    WORD      wPid;
    ;    MMVERSION vDriverVersion;
    ;    CHAR      szPname[MAXPNAMELEN];
    ;    WORD      wTechnology;
    ;    WORD      wVoices;
    ;    WORD      wNotes;
    ;    WORD      wChannelMask;
    ;    DWORD     dwSupport;

    MidiOutCaps := Buffer(50, 0)  ; allows for szPname to be 32 bytes ; V1toV2: if 'MidiOutCaps' is a UTF-16 string, use 'VarSetStrCapacity(&MidiOutCaps, 50)'
    OffsettoPortName := 8, PortNameSize := 32
    result := DllCall("winmm.dll\midiOutGetDevCapsA", "UInt", uDeviceID, "UInt", MidiOutCaps, "UInt", 50, "UInt")

    If (result OR ErrorLevel) {
        MsgBox("Error " result " (ErrorLevel = " ErrorLevel ") in retrieving the name of midi output " uDeviceID)
        Return -1
      }

    VarSetStrCapacity(&PortName, PortNameSize) ; V1toV2: if 'PortName' is NOT a UTF-16 string, use 'PortName := Buffer(PortNameSize)'
    DllCall("RtlMoveMemory", "Str", PortName, "Uint", MidiOutCaps+OffsettoPortName, "Uint", PortNameSize)
    Return PortName
  }

MidiOutsEnumerate() { ; Returns number of midi output devices, creates global array MidiOutPortName with their names
    local NumPorts, PortID
    MidiOutPortName := ""
    NumPorts := MidiOutGetNumDevs()

    Loop NumPorts {
        PortID := A_Index -1
        MidiOutPortName%PortID% := MidiOutNameGet(PortID)
      }
    Return NumPorts
  }

UInt@(ptr) {
Return *ptr | *(ptr+1) << 8 | *(ptr+2) << 16 | *(ptr+3) << 24
}

PokeInt(p_value, p_address) { ; Windows 2000 and later
    DllCall("ntdll\RtlFillMemoryUlong", "UInt", p_address, "UInt", 4, "UInt", p_value)
}

;*************************************************
;*      MIDI INPUT / OUTPUT UNDER THE HOOD
;*************************************************

;########MIDI LIB from orbik and lazslo#############
;-------- orbiks midi input code --------------
; Set up midi input and callback_window based on the ini file above.
; This code copied from ahk forum Orbik's post on midi input
; nothing below here to edit.
; =============== midi in =====================

Midiin_go:
DeviceID := MidiInDevice                  ; midiindevice from IniRead above assigned to deviceid
CALLBACK_WINDOW := 0x10000    ; from orbiks code for midi input

oGui7.Opt("+LastFound")                                ; set up the window for midi data to arrive.
hWnd := WinExist()                           ;MsgBox, 32, , line 176 - mcu-input  is := %MidiInDevice% , 3 ; this is just a test to show midi device selection

hMidiIn := ""
hMidiIn := Buffer(4, 0) ; V1toV2: if 'hMidiIn' is a UTF-16 string, use 'VarSetStrCapacity(&hMidiIn, 4)'
  result := DllCall("winmm.dll\midiInOpen", "UInt", hMidiIn, "UInt", DeviceID, "UInt", hWnd, "UInt", 0, "UInt", CALLBACK_WINDOW, "UInt")
    If result
      {
        MsgBox("Error, midiInOpen Returned " result "`n")
        ;GoSub, sub_exit
      }

hMidiIn := NumGet(hMidiIn, "UPtr")              ; because midiInOpen writes the value in 32 bit binary Number, AHK stores it as a string
  result := DllCall("winmm.dll\midiInStart", "UInt", hMidiIn)
    If result
      {
        MsgBox("Error, midiInStart Returned " result "`nRight Click on the Tray Icon - Left click on MidiSet to select valid midi_in port.")
        ;GoSub, sub_exit
      }

OpenCloseMidiAPI()
    ; ----- the OnMessage listeners ----
    ; LEFT HERE FOR REFERENCE
      ; #define MM_MIM_OPEN 0x3C1 /* MIDI input */
      ; #define MM_MIM_CLOSE 0x3C2
      ; #define MM_MIM_DATA 0x3C3
      ; #define MM_MIM_LONGDATA 0x3C4
      ; #define MM_MIM_ERROR 0x3C5
      ; #define MM_MIM_LONGERROR 0x3C6

    OnMessage(0x3C1, MidiMsgDetect)  ;  See top of this file for function called when a midi message is detected
    OnMessage(0x3C2, MidiMsgDetect)  
    OnMessage(0x3C3, MidiMsgDetect)
    OnMessage(0x3C4, MidiMsgDetect)
    OnMessage(0x3C5, MidiMsgDetect)
    OnMessage(0x3C6, MidiMsgDetect)

Return

;*************************************************
;*          MIDI IN PORT HANDLING
;*************************************************

MidiInsList(&NumPorts)                                             ; should work for unicode now... 
  { ; Returns a "|"-separated list of midi output devices
    local List, MidiInCaps, PortName, result, midisize
  (1)? offsetWordStr := 64: offsetWordStr := 32
  midisize := offsetWordStr + 18
    MidiInCaps := Buffer(midisize, 0) ; V1toV2: if 'MidiInCaps' is a UTF-16 string, use 'VarSetStrCapacity(&MidiInCaps, midisize)'
    VarSetStrCapacity(&PortName, offsetWordStr)                       ; PortNameSize 32 ; V1toV2: if 'PortName' is NOT a UTF-16 string, use 'PortName := Buffer(offsetWordStr)'

    NumPorts := DllCall("winmm.dll\midiInGetNumDevs") ; #midi output devices on system, First device ID = 0

    Loop NumPorts
      {
        result := DllCall("winmm.dll\midiInGetDevCaps", "UInt", A_Index-1, "Ptr", MidiInCaps, "UInt", midisize)
    
        If (result OR ErrorLevel) {
            List .= "|-Error-"
            Continue
          }
    PortName := StrGet(&MidiInCaps + 8, offsetWordStr)
        List .= "|" PortName
      }
    Return SubStr(List, 2)
  }

MidiInGetNumDevs() { ; Get number of midi output devices on system, first device has an ID of 0
    Return DllCall("winmm.dll\midiInGetNumDevs")
  }
MidiInNameGet(uDeviceID := 0) {                  ; Get name of a midiOut device for a given ID

;MIDIOUTCAPS struct
;    WORD      wMid;
;    WORD      wPid;
;    MMVERSION vDriverVersion;
;    CHAR      szPname[MAXPNAMELEN];
;    WORD      wTechnology;
;    WORD      wVoices;
;    WORD      wNotes;
;    WORD      wChannelMask;
;    DWORD     dwSupport;

    MidiInCaps := Buffer(50, 0)               ; allows for szPname to be 32 bytes ; V1toV2: if 'MidiInCaps' is a UTF-16 string, use 'VarSetStrCapacity(&MidiInCaps, 50)'
    OffsettoPortName := 8, PortNameSize := 32
    result := DllCall("winmm.dll\midiInGetDevCapsA", "UInt", uDeviceID, "UInt", MidiInCaps, "UInt", 50, "UInt")

    If (result OR ErrorLevel) {
        MsgBox("Error " result " (ErrorLevel = " ErrorLevel ") in retrieving the name of midi Input " uDeviceID)
        Return -1
      }

    VarSetStrCapacity(&PortName, PortNameSize) ; V1toV2: if 'PortName' is NOT a UTF-16 string, use 'PortName := Buffer(PortNameSize)'
    DllCall("RtlMoveMemory", "Str", PortName, "Uint", MidiInCaps+OffsettoPortName, "Uint", PortNameSize)
    Return PortName
  }

MidiInsEnumerate() { ; Returns number of midi output devices, creates global array MidiOutPortName with their names
    local NumPorts, PortID
    MidiInPortName := ""
    NumPorts := MidiInGetNumDevs()

    Loop NumPorts {
        PortID := A_Index -1
        MidiInPortName%PortID% := MidiInNameGet(PortID)
      }
    Return NumPorts
  }









