;*************************************************
;*          GET PORTS LIST AND PARSE
;*************************************************

MidiPortRefresh:                                    ; get the list of ports

    MIlist := MidiInsList(NumPorts)        ; Get midi inputs list
    Loop Parse, MIlist, | {
    }
        TheChoice := MidiInDevice + 1

    MOlist := MidiOutsList(NumPorts2)   ; Get midi outputs list
    Loop Parse, MOlist, | {
    }
        TheChoice2 := MidiOutDevice + 1

    return


    ;*************************************************
    ;*          CHECK .INI file for previous configuration
    ;*************************************************
    ;-----------------------------------------------------------------

    ReadIni()                                         ; Read .ini file to load port settings - also set up the tray Menu
    {
        Menu, tray, add, MidiSet           ; set midi ports tray item
        Menu, tray, add, ResetAll          ; DELETE THE .INI FILE - a new config needs to be set up
        menu, tray, add, MidiMon        ; Menu item for the midi monitor
        global MidiInDevice, MidiOutDevice, version ; version var is set at the beginning.
        IfExist, %version%.ini
        {
            IniRead, MidiInDevice, %version%.ini, Settings, MidiInDevice, %MidiInDevice%            ; read the midi In port from ini file
            IniRead, MidiOutDevice, %version%.ini, Settings, MidiOutDevice, %MidiOutDevice%   ; read the midi out port from ini file
        }
        Else                                                                                    ; no ini exists and this is either the first run or reset settings.
        {
            MsgBox, 1, No ini file found, Select midi ports ?      ; Prompt user to select midi ports
                IfMsgBox, Cancel
                ExitApp
                IfMsgBox, yes
                gosub, midiset     ; run the midi setup routine
            }
        } ; endof readini

        ;*************************************************
        ;*   WRITE TO INI FILE FUNCTION  + UPDATE INI WHENEVER SAVED PARAMETERS CHANGE
        ;*************************************************

        WriteIni()                                                                  ; Write selections to .ini file
        {
            global MidiInDevice, MidiOutDevice, version
            IfNotExist, %version%.ini                                   ; if no .ini
            FileAppend, , %version%.ini                              ; make  .ini with the following entries.
            IniWrite, %MidiInDevice%, %version%.ini, Settings, MidiInDevice
            IniWrite, %MidiOutDevice%, %version%.ini, Settings, MidiOutDevice
        }

        ;*************************************************
        ;*                 PORT TESTING
        ;*************************************************

        port_test(numports, numports2)                             ; confirm selected ports exist ; CLEAN THIS UP STILL
        {
            global midiInDevice, midiOutDevice, midiok    ; Set varibles to golobal

            ;; =============== In port selection test based on numports ; ===============
            If MidiInDevice not Between 0 and %numports%
            {
                MidiIn := 0 ; this var is just to show if there is an error - set if the ports are valid = 1, invalid = 0
                ;MsgBox, 0, , midi in port Error ; (this is left only for testing)
                If (MidiInDevice = "")                                      ; if there is no midi in device
                    MidiInerr = Midi In Port EMPTY.                ; set this var = error message
                ;MsgBox, 0, , midi in port EMPTY
                If (midiInDevice > %numports%)                  ; if greater than the number of ports on the system.
                    MidiInnerr = Midi In Port Invalid.              ; set this error message
                ;MsgBox, 0, , midi in port out of range
            }
            Else
            {
                MidiIn := 1                                                     ; setting var to non-error state or valid
            }
            ; =============== out port selection test based on numports2 ; ===============
            If MidiOutDevice not Between 0 and %numports2%
            {
                MidiOut := 0                                                    ; set var to 0 as Error state.
                If (MidiOutDevice = "")                                  ; if blank
                    MidiOuterr = Midi Out Port EMPTY.         ; set this error message
                ;MsgBox, 0, , midi o port EMPTY - THIS LINE IS JUST FOR TESTING
                If (midiOutDevice > %numports2%)             ; if greater than number of availble ports
                    MidiOuterr = Midi Out Port Out Invalid.  ; set this error message
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
                MsgBox, 49, Midi Port Error !, %MidiInerr%`
                n%MidiOuterr%`
                n`
                nLaunch Midi Port Selection !
                    IfMsgBox, Cancel
                ExitApp
                midiok = 0                                                      ; Not sure if this is really needed now....
                Gosub, MidiSet                                               ;Gui, show Midi Port Selection
            }
            Else
            {
                midiok = 1
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


        MidiOutsList(ByRef NumPorts)                        ; works with unicode now
        { ; Returns a "|"-separated list of midi output devices
            local List, MidiOutCaps, PortName, result, midisize
            (A_IsUnicode) ? offsetWordStr := 64 : offsetWordStr := 32
            midisize := offsetWordStr + 18
            VarSetCapacity(MidiOutCaps, midisize, 0)
            VarSetCapacity(PortName, offsetWordStr)                             ; PortNameSize 32

            NumPorts := DllCall("winmm.dll\midiOutGetNumDevs")   ; midi output devices on system, First device ID = 0

            Loop %NumPorts%
            {
                result := DllCall("winmm.dll\midiOutGetDevCaps", "Uint", A_Index - 1, "Ptr", &MidiOutCaps, "Uint", midisize)

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
                DllCall("FreeLibrary", UInt, hModule), hModule := ""
            If (0 = hModule := DllCall("LoadLibrary", Str, "winmm.dll")) {
                MsgBox Cannot load libray winmm.dll
                Exit
            }
        }

        ; ===============FUNCTIONS FOR SENDING SHORT MESSAGES ; ===============

        midiOutOpen(uDeviceID = 0) { ; Open midi port for sending individual midi messages --> handle
            strh_midiout = 0000

            result := DllCall("winmm.dll\midiOutOpen", UInt, &strh_midiout, UInt, uDeviceID, UInt, 0, UInt, 0, UInt, 0, UInt)
            If (result or ErrorLevel) {
                MsgBox There was an Error opening the midi port.`
                nError code %result%`
                nErrorLevel = %ErrorLevel%
                Return -1
            }
            Return UInt@
            (&strh_midiout)
        }
        ;*****************************************************************
        ;   ALL MIDI SENT TO THE OUTPUT MIDI PORT - CALLS THIS FUNCTION
        ;*****************************************************************

        midiOutShortMsg(h_midiout, MidiStatus, Param1, Param2) { ;Channel,
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
            result := DllCall("winmm.dll\midiOutShortMsg", UInt, h_midiout, UInt, MidiStatus | (Param1 << 8) | (Param2 << 16), UInt)
            If (result or ErrorLevel) {
                MsgBox There was an Error Sending the midi event: (%result%`
                    , %ErrorLevel%)
                Return -1
            }
        }     ; ends midi out function

        midiOutClose(h_midiout) {  ; Close MidiOutput
            Loop 9 {
                result := DllCall("winmm.dll\midiOutClose", UInt, h_midiout)
                If !(result or ErrorLevel)
                    Return
                Sleep 250
            }
            MsgBox Error in closing the midi output port.
            There may still be midi events being Processed.
            Return -1
        }

        ;UTILITY FUNCTIONS
        MidiOutGetNumDevs() { ; Get number of midi output devices on system, first device has an ID of 0
            Return DllCall("winmm.dll\midiOutGetNumDevs")
        }

        MidiOutNameGet(uDeviceID = 0) { ; Get name of a midiOut device for a given ID

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

            VarSetCapacity(MidiOutCaps, 50, 0)  ; allows for szPname to be 32 bytes
            OffsettoPortName := 8, PortNameSize := 32
            result := DllCall("winmm.dll\midiOutGetDevCapsA", UInt, uDeviceID, UInt, &MidiOutCaps, UInt, 50, UInt)

            If (result OR ErrorLevel) {
                MsgBox Error %result% (ErrorLevel = %ErrorLevel%) in retrieving the name of midi output %uDeviceID%
                Return -1
            }

            VarSetCapacity(PortName, PortNameSize)
            DllCall("RtlMoveMemory", Str, PortName, Uint, &MidiOutCaps + OffsettoPortName, Uint, PortNameSize)
            Return PortName
        }

        MidiOutsEnumerate() { ; Returns number of midi output devices, creates global array MidiOutPortName with their names
            local NumPorts, PortID
            MidiOutPortName =
                NumPorts := MidiOutGetNumDevs()

            Loop %NumPorts% {
                PortID := A_Index - 1
                MidiOutPortName%PortID% := MidiOutNameGet(PortID)
            }
            Return NumPorts
        }

        UInt@
        (ptr) {
            Return * ptr | * (ptr + 1) << 8 | * (ptr + 2) << 16 | * (ptr + 3) << 24
        }

        PokeInt(p_value, p_address) { ; Windows 2000 and later
            DllCall("ntdll\RtlFillMemoryUlong", UInt, p_address, UInt, 4, UInt, p_value)
        }
