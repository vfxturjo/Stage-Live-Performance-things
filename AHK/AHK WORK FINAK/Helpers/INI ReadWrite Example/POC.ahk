MyIni := Ini('test.ini')
MyIni.section.key := 'value'
MsgBox MyIni.section.key
MsgBox MyIni.section.key2['default value']
MyIni.section.key2 := 'value2'
MsgBox MyIni.section.key2['default value']

class Ini {
    __New(iniFilePath) => this.__path__ := iniFilePath
    __Get(name, *)     => Ini.Section(this.__path__, name)

    class Section {
        __New(iniFilePath, sectionName) {
            this.DefineProp('__path__', { get: (*) => iniFilePath })
            this.DefineProp('__name__', { get: (*) => sectionName })
        }
        __Get(keyName, default) => IniRead(this.__path__, this.__name__, keyName, default.Has(1) ? default[1] : '')
        __Set(keyName,_, value) => IniWrite(value, this.__path__, this.__name__, keyName)
    }
}