; vk_code := GetKeyVK("Esc")
; MsgBox Format("vk{:X}", vk_code) ; Reports vk1B


keys := {}
unique_mode := 0

Gui, Add, ListView, w200 h300, Key | SC
LV_ModifyCol(1, 100)
LV_ModifyCol(2, 60)
LV_ModifyCol(3, 60)
replacements := { 33: "PgUp", 34: "PgDn", 35: "End", 36: "Home", 37: "Left", 38: "Up", 39: "Right", 40: "Down", 45: "Insert", 46: "Delete" }
;replacements := {}
count := 0
Loop 350 {
    ; Get the key name
    code := Format("{:x}", A_Index)
    if (ObjHasKey(replacements, A_Index)) {
        n := replacements[A_Index]
    } else {
        n := GetKeyName("vk" code)
    }
    if (n = "" || (unique_mode ? ObjHasKey(keys, n) : 0))
        continue
    LV_Add(, n, code)
    keys[n] := 1
    fn := Func("action").Bind(A_Index, code, n, 1)
    hotkey, %"~" n, % fn
    fn := Func("action").Bind(A_Index, code, n, 0)
    hotkey, %"~" n " up", % fn
    count++
}
Gui, Add, Text, xm, %"Total: " count
Gui Show, x0 y0
return

action(dec, hex, n, event) {
    if (event) {
        ToolTip, %n " (" dec "/ Ox" hex ")"
    } else {
        ToolTip
    }
}

GuiClose:
    ExitApp
