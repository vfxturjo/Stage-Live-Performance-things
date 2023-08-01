<!--
Created: Sun Jul 23 2023 13:16:06 GMT+0600 (Bangladesh Standard Time)
Modified: Wed Aug 02 2023 05:59:03 GMT+0600 (Bangladesh Standard Time)
-->

# fix radio button for selecting keybinding settings

# Fix pitchBend error

tab and tilde key again and again together -> stuck with pitch 50 105. 
need to fix it

# ask for saving changes in settingsGUI
* keep a temporary file, then if apply ok, delete
* another way: see changes live
# Auto-legato

Based on:
* pitch bend range
* playing speed
* previous note

## logic

* the notes held are in an array.
* when a new note is pressed

> - if distance(last note and new note) <= pitch bend range: then legato
>> - new pitch = distance / range * 100
>> - bending speed ≡ playing speed modified by hi/low limits (last n seconds average frequency of key strokes)

## playing speed

suppose n second range = 4 seconds range
played 10 notes.
distance between notes = 4/10 = time / numberOfNotes

when a key is pressed. keyCount++, and set a timer for n seconds to keyCount-- it after timeOut. dont do it for all ticks
do this after every 250ms
