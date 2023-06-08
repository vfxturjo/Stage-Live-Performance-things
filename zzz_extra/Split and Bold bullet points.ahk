#NoEnv
SendMode Input

SplitAndBoldText()
{
    Clipboard := "" ; Clear the clipboard
    SendInput, ^c ; Copy selected text
    ClipWait, 1 ; Wait for the clipboard to contain data
    Send, {BS}

    if (!ErrorLevel) ; If clipboard contains data
    {
        lines := StrSplit(Clipboard, "`n") ; Split clipboard content into lines

        Loop, % lines.MaxIndex() ; Iterate through each line
        {
            line := lines[A_Index] ; Get the current line
            line := Trim(line) ; get clean trimmed line

            if (line == "" || line == "`r" || line == "'n"){
                Continue
            }

            colonIndex := InStr(line, ":") ; Find the index of the colon

            if (colonIndex > 0) ; If colon is found in the line
            {
                pointName := SubStr(line, 1, colonIndex) ; Extract the point name
                pointContent := SubStr(line, colonIndex + 2) ; Extract the point content (excluding the space after the colon)

                Send, {LControl Down}{. Down}{. Up}{LControl Up}
                SendInput, ^b{Raw}%pointName%
                SendInput, +{Enter}
                SendInput, ^b{Raw}%pointContent%
            }
            else ; if no colon is found. simple paste
            {
                SendInput, {Raw}%line%
            }
        }
    }
}

!q::SplitAndBoldText() ; Map Alt+q to execute the SplitAndBoldText function
