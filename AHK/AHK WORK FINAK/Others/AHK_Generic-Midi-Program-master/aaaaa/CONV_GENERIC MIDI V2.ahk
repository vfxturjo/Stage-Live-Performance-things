#Include MidiRules.ahk
#Include hotkeyTOmidi_1.ahk
#Include hotkeyTOmidi_2.ahk

#Persistent
#SingleInstance , force
SendMode Input
SetWorkingDir %A_ScriptDir%
if A_OSVersion in WIN_NT4, WIN_95, WIN_98, WIN_ME
{
    MsgBox This script requires Windows 2000 / XP or later.
    ExitApp
}
version = Generic_Midi_App_0.71
readini()
gosub, MidiPortRefresh
port_test(numports, numports2)
gosub, midiin_go
gosub, midiout
gosub, midiMon

channel = 1
CC_num = 7
CCIntVal = 0
CCIntDelta = 1

settimer, KeyboardCCs, 50

RelayCC:
    MidiOutDisplay("CC", statusbyte, chan, CC_num, data2)
    midiOutShortMsg(h_midiout, (Channel + 175), CC_num, CCIntVal)
    Return

SendCC:
    midiOutShortMsg(h_midiout, (Channel + 175), CC_num, CCIntVal)
    stb := "CC"
    statusbyte := (Channel + 174)
    data1 = %CC_num%
    data2 = %CCIntVal%
    MidiOutDisplay(stb, statusbyte, channel, data1, data2)
    Return

RelayNote:
    midiOutShortMsg(h_midiout, statusbyte, data1, data2)
    stb := "NoteOn"
    MidiOutDisplay(stb, statusbyte, chan, data1, data2)
    Return

SendNote:
    note = %data1%
    vel = %data2%
    midiOutShortMsg(h_midiout, statusbyte, note, vel)
    stb := "NoteOn"
    statusbyte := 144
    chan = %channel%
    data1 = %Note%
    data2 = %Vel%
    MidiOutDisplay(stb, statusbyte, chan, data1, data2)
    Return

SendPC:
    midiOutShortMsg(h_midiout, (Channel + 191), pc, data2)
    stb := "PC"
    statusbyte := 192
    chan = %channel%
    data1 = %PC%
    data2 =
        MidiOutDisplay(stb, statusbyte, chan, data1, data2)
    Return
