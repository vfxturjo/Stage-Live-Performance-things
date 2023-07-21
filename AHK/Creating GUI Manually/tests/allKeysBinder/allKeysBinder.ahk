class AllKeyBinder {
    __New(callback, pfx := "~*") {
        keys := Map()
        this.Callback := callback
        Loop 512 {
            i := A_Index
            code := Format("{:x}", i)
            n := GetKeyName("sc" code)
            if (!n || keys.HasProp(n))
                continue

            keys[n] := code

            fn := this.KeyEvent.Bind(this, i, n, 1)
            Hotkey(pfx "SC" code, fn, "On")

            fn := this.KeyEvent.Bind(this, i, n, 0)
            Hotkey(pfx "SC" code " up", fn, "On")
        }
    }

    KeyEvent(code, name, state, *) {
        this.Callback.Call(code, name, state)
    }
}
