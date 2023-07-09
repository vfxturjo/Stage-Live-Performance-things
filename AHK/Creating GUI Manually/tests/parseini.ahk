Filename := "settings.ini"
Section := "keys"


keysList := [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
]


; for key, Value in keysList
; {
;     ; Value := IniRead(Filename, Section, Key, "Not Set")
;     Value := IniRead(Filename, Section, Value, "Not Set")
;     MsgBox Value

; }

IniWrite("yes", Filename, Section, "F6")
