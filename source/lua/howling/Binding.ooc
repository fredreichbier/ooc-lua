use luajit
import lua/State

import _howling

BindingError: class extends Exception {
    init: func (=message) {
        super(message)
    }
}

Binding: class {
    state: State

    init: func (=state, path: String) {
        initHowling(path)
    }

    init: func ~newState (path: String) {
        init(State new(), path)
    }

    initHowling: func (path: String) {
        // load libraries (howling needs them)
        state openLibs()
        // load the module
        err := state loadString(_HOWLING_LUA)
        if(err != 0) {
            BindingError new("Couldn't load howling lua code: #{state toString(-1)}") throw()            
        }
        // run the module and add it to package.loaded
        err = state pcall(0, 1, 0)
        if(err != 0) {
            BindingError new("Couldn't execute howling lua code: #{state toString(-1)}") throw() 
        }
        state getGlobal("package")
        state getField(-1, "loaded")
        // we need the howling module once again.
        state pushValue(-3)
        /* now the stack looks like this:
       
            howling module (top) 
            package.loaded 
            package
            howling module
        */
        state setField(-2, "howling") // package.loaded["howling"] = howling
        // let's remove everything we don't need anymore.
        state pop(3)
        // and now, call "howling.init()"
        quotedPath := path replaceAll("\"", "\\\"")
        runString("local howling = require(\"howling\")
                   howling.init(\"#{quotedPath}\")")
    }

    runFile: func (filename: String) {
        state loadFile(filename)
        _executeCode()
    }

    runString: func (code: String) {
        state loadString(code)
        _executeCode()
    }

    _executeCode: func {
        // run the module and add it to package.loaded
        err := state pcall(0, 0, 0)
        if(err != 0) {
            BindingError new("Couldn't execute lua code: #{state toString(-1)}") throw() 
        }
    }

}
