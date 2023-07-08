MsgBox(A_WorkingDir)

keyValuePairs := Map(
    "hi", Map(
        "SETTING1", 10,
        "SETTING2", 100,
        "SETTING3", 1000
    ),
    "there", Map(
        "SETTING1", 10,
        "SETTING2", 100,
        "SETTING3", 1000
    )
)


; WriteINI(&keyValuePairs, A_WorkingDir . "/test.ini",)

Settings := ReadINI(A_WorkingDir . "/test.ini")

MsgBox Settings.hi.SETTING3

;-------------------------------------------------------------------------------
WriteINI(&Array2D, INI_File) {	; write 2D-array to INI-file
    ;-------------------------------------------------------------------------------
    for SectionName, Entry in Array2D {
        Pairs := ""
        for Key, Value in Entry
            Pairs .= Key "=" Value "`n"
        IniWrite(Pairs, INI_File, SectionName)
    }
}

;-------------------------------------------------------------------------------
ReadINI(INI_File, oResult := "") {	; return 2D-array from INI-file
    oResult := IsObject(oResult) ? oResult : []
    oResult.Section := []
    SectionNames := IniRead(INI_File)
    for each, Section in StrSplit(SectionNames, "`n") {
        OutputVar_Section := IniRead(INI_File, Section)
        if !oResult.HasOwnProp(Section) {
            oResult.%Section% := []
        }
        for each, Haystack in StrSplit(OutputVar_Section, "`n") {
            RegExMatch(Haystack, "(.*?)=(.*)", &match)
            ArrayProperty := match[1]
            oResult.%Section%.%ArrayProperty% := match[2]
        }
    }
    return oResult
}
