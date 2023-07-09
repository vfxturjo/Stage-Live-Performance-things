IB := InputBox("example: C#5", "MidiOut for ", "w150 h100")
if (IB.Result != "Cancel") {

    ; Check if value is valid
    if (RegExMatch(IB.Value, "([a-zA-Z]#\d|[a-zA-Z]\d)")) {
        MsgBox "true"
    }
    else
        MsgBox "false"
}
