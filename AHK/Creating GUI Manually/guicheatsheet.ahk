size := "w20 h20"

;-- Defaults
; Default first control placement: top-left corner
myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.OnEvent("Escape", GuiClose)
ogcButtonA := myGui.Add("Button", size, "A")
; Default next placement: just below the previous one
ogcButtonB := myGui.Add("Button", size, "B")

;-- Moves relative to bottom or right of previously added control
; Offset toward bottom
ogcButtonC := myGui.Add("Button", size . " y+50", "C")
; Offset toward right
ogcButtonD := myGui.Add("Button", size . " x+50", "D")
; Offset toward top
ogcButtonE := myGui.Add("Button", size . " y+-50", "E")
; Offset toward left
ogcButtonF := myGui.Add("Button", size . " x+-50", "F")
;-- Absolute
ogcButtonG := myGui.Add("Button", size . " x150 y150", "G")

;-- Moves relative to top-left corner of previously added control
; Offset toward left
ogcButtonH := myGui.Add("Button", size . " xp-40", "H")
; Offset toward right
ogcButtonI := myGui.Add("Button", size . " xp+80", "I")
; Offset toward top
ogcButtonJ := myGui.Add("Button", size . " yp-40", "J")
; Offset toward bottom
ogcButtonK := myGui.Add("Button", size . " yp+80", "K")

;-- Margin relative moves
; Left margin, below all previous controls
ogcButtonL := myGui.Add("Button", size . " xm", "L")
; Top margin, on right of all previous controls
ogcButtonM := myGui.Add("Button", size . " ym", "M")
; Reset to top-left corner (moved to avoid overlaying 'A' button)
ogcButtonN := myGui.Add("Button", size . " xm+20 ym+20", "N")
; Left margin + move, below all previous controls
ogcButtonO := myGui.Add("Button", size . " xm+30", "O")
; Top margin + move, on right of all previous controls
ogcButtonP := myGui.Add("Button", size . " ym+30", "P")

;-- Another absolute position, starting a section
ogcButtonQ := myGui.Add("Button", size . " x240 y240 Section", "Q")
; Default position
ogcButtona := myGui.Add("Button", size, "a")
ogcButtonb := myGui.Add("Button", size, "b")

;-- Section relative moves
; Start a new column (relative to previous Section declaration)
ogcButtonT := myGui.Add("Button", size . " ys", "T")
; Default
ogcButtonc := myGui.Add("Button", size, "c")
ogcButtond := myGui.Add("Button", size, "d")
; New column
ogcButtonU := myGui.Add("Button", size . " ys Section", "U")
; New column (horizontal placement)
ogcButtone := myGui.Add("Button", size . " ys", "e")
; New column; and move a bit on the right
ogcButtonf := myGui.Add("Button", size . " ys x+20", "f")
; New row (relative to previous Section declaration)
ogcButtonV := myGui.Add("Button", size . " xs Section", "V")
; New column (horizontal placement)
ogcButtong := myGui.Add("Button", size . " ys", "g")
; New column; and move a bit on the right
ogcButtonh := myGui.Add("Button", size . " ys x+20", "h")
; New row (relative to previous Section declaration), move to bottom
ogcButtonW := myGui.Add("Button", size . " xs y+20 Section", "W")
; New column (horizontal placement)
ogcButtoni := myGui.Add("Button", size . " ys", "i")
; New column; and move a bit on the right
ogcButtonj := myGui.Add("Button", size . " ys x+20", "j")

myGui.Show()
Return

GuiClose(*)
{ ; V1toV2: Added bracket
GuiEscape:
    ExitApp()

} ; Added bracket in the end
