class AllKeyBinder {
    __New(callback, pfx := "~*") {
        keys := Map()
        this.Callback := callback
        Loop 512 {
            i := A_Index
            code := Format("{:x}", i)
            n := GetKeyName("sc" code)
            vkCode := GetKeyVK(n)
            if (!n || keys.HasProp(n))
                continue

            keys[n] := code

            fn := this.KeyEvent.Bind(this, i, vkCode, n, pfx "SC" code, 1)
            Hotkey(pfx "SC" code, fn, "On")

            ; fn := this.KeyEvent.Bind(this, i, vkCode, n, 0)
            ; Hotkey(pfx "SC" code " up", fn, "On")
        }
    }

    KeyEvent(SCcode, codeVK, name, SCcodeMain, state, *) {
        this.Callback.Call(SCcode, codeVK, name, SCcodeMain, state)
    }
}

kb := AllKeyBinder(MyFunc)


global listOfHotkeys := []
MyFunc(SCcode, codeVK, name, SCcodeMain, state) {
    ; ToolTip("Key Code: " SCcode ", VK:" codeVK ", Name: " name ", State: " state)
    guiText2.Text := "SCCode: " SCcode ", VK:" codeVK ", Name: " name ", State: " state

    tempList := ["VKcode ", codeVK, "`tSCcode ", SCcode, "`t`tName ", name, "`t`tMainSCcode ", SCcodeMain]
    global listOfHotkeys

    for entry in listOfHotkeys {
        if entry[2] == (codeVK) {
            return
        }
    }
    listOfHotkeys.Push(tempList)
}

OnExit(SaveListToTextFileCALL)


SaveListToTextFileCALL(*) {
    SaveListToTextFile("availableButtons.txt", listOfHotkeys, 2)
}

SaveListToTextFile(fileName, list, level) {
    if level == 2 {
        for key, entry in list {
            Str := ""
            For Index, Value In entry {
                Str := Str " " Value
            }

            FileAppend("`n" Str, fileName)
        }
    }
}


; #region Creating Midi player window
window := gui('+LastFound +AlwaysOnTop -SysMenu')
WinSetTransparent 225
window.SetFont 's11', 'Segoe UI'
guiText := window.add('text', 'w280 h200')
guiText2 := window.add('text', 'w280 h20')
statusBar := window.add('StatusBar')
window.show()
; #endregion
return

^Esc::
{
    ExitApp()
}
