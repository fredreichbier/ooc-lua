use luajit
import lua/State

import _howling

BindingError: class extends Exception {
    init: func (=message) {
        super(message)
    }
}

howling_traceback_handler: func (state: State) -> Int {
    if (!state isString(1)) { // message not a string?
        return 1 // keep it intact
    }

    state getGlobal(c"debug")
    if (!state isTable(-1)) {
        state pop(1)
        return 1
    }

    state getField(-1, c"traceback")
    if (!state isFunction(-1)) {
        state pop(2)
        return 1
    }

    state pushValue(1) // pass error message
    state pushInteger(2) // skip this function and traceback
    state call(2, 1) // call debug.traceback
    1
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

        // install traceback handler
        state pushCFunction(howling_traceback_handler)

        // load the module
        err := state loadString(_HOWLING_LUA)
        _checkErrors(err, "load howling lua code")

        // run the module and add it to package.loaded
        err = state pcall(0, 1, state getTop() - 1)
        _checkErrors(err, "execute howling lua code")

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
        err := state loadFile(filename)
        _checkErrors(err, "load lua code")
        _executeCode()
    }

    runString: func (code: String) {
        err := state loadString(code)
        _checkErrors(err, "load lua code")
        _executeCode()
    }

    _executeCode: func {
        // run the module and add it to package.loaded
        err := state pcall(0, 0, 1)
        _checkErrors(err, "execute lua code")
    }

    _checkErrors: func (err: Int, action: String) {
        if (err == 0) return
        message := state toString(-1)
        BindingError new("Couldn't #{action}: #{message}") throw() 
    }

}
