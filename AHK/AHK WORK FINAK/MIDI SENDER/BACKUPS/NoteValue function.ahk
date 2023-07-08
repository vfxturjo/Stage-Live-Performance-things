_noteValue(note)
{
    ; Extract note name and octave using regex
    match := []
    regexMatch(note, "(\D+)(\d+)", &match)
    ; note_name := match[1] ,,,,, octave := match[2]
    return 12 * match[2] + Map(
        "C", 0,
        "C#", 1,
        "D", 2,
        "D#", 3,
        "E", 4,
        "F", 5,
        "F#", 6,
        "G", 7,
        "G#", 8,
        "A", 9,
        "A#", 10,
        "B", 11
    )[match[1]]
}
