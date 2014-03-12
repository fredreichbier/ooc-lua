use luajit
import lua/State

import _howling

BindingError: class extends Exception {
    init: func (=message) {
        super(message)
    }
}

_TRACEBACK_LUA := "
local onerror = function (err)
    print('err:' .. err)

    if package.loaded['moonscript.errors'] then
        print('got moonscript')

        local trace = debug.traceback('', 2)
        print('trace:' .. trace)

        -- rewrite using .moon line numbers
        local errors = require('moonscript.errors')
        print('required errors!')
        print('it is: ' .. tostring(errors))

        local util = require('moonscript.util')
        print('required util!')
        print('it is: ' .. tostring(util))

        local truncated = errors.truncate_traceback(util.trim(trace))
        print('truncated: ' .. tostring(truncated))

        local rewritten = errors.rewrite_traceback(trace, err)
        print('rewritten: ' .. tostring(rewritten))

        if rewritten then
            return rewritten
        else
            return trace
        end
    else
        -- skip this function and traceback
        return debug.traceback(err, 2)
    end
end

print('Lua error code loaded')
return onerror
"

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

// custom lua allocator based on Boehm GC
lalloc: func (ud: Pointer, ptr: Pointer, osize: SizeT, nsize: SizeT) -> Pointer {
    if (nsize == 0) {
        gc_free(ptr)
        return null
    }

    if (osize == 0) {
        return gc_malloc_uncollectable(nsize)
    }

    return gc_realloc(ptr, nsize)
}

Binding: class {
    state: State
    tracebackHandlerIndex: Int

    init: func (=state, path: String) {
        initHowling(path)
    }

    init: func ~newState (path: String) {
        init(State new(lalloc, null), path)
    }

    initHowling: func (path: String) {
        // load libraries (howling needs them)
        state openLibs()

        // install traceback handler
        // Since we push it at the very beginning, it will
        // always be at index 1. See tracebackHandlerIndex.
        // state pushCFunction(howling_traceback_handler)
        err := state loadString(_TRACEBACK_LUA)
        _checkErrors(err, "load traceback lua code")

        err = state pcall(0, 1, tracebackHandlerIndex)
        _checkErrors(err, "executing traceback lua code")

        tracebackHandlerIndex = state getTop()
        "Traceback code installed, index = %d" printfln(tracebackHandlerIndex)

        // load the module
        err = state loadString(_HOWLING_LUA)
        _checkErrors(err, "load howling lua code")

        // run the module and add it to package.loaded
        err = state pcall(0, 1, tracebackHandlerIndex)
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
            <exception handler>
        */
        state setField(-2, "howling") // package.loaded["howling"] = howling
        // let's remove everything we don't need anymore. Keep the howling module
        // for now.
        state pop(2)
        // call howling.init.
        state getField(-1, "init")
        state pushString(path)
        err = state pcall(1, 0, tracebackHandlerIndex)
        _checkErrors(err, "initialize howling")
        // finally pop the howling module
        state pop(1)
    }

    runFile: func (filename: String) {
        err := state loadFile(filename)
        _checkErrors(err, "load lua code")
        pcall()
    }

    runString: func (code: String) {
        err := state loadString(code)
        _checkErrors(err, "load lua code")
        pcall()
    }

    pcall: func ~boring {
        pcall(0, 0, "execute lua code")
    }

    pcall: func (nargs, nresults: Int, action: String) {
        err := state pcall(nargs, nresults, tracebackHandlerIndex)
        _checkErrors(err, action)
    }

    _checkErrors: func (err: Int, action: String) {
        if (err == 0) return
        message := state toString(-1)
        BindingError new("Couldn't #{action}: #{message}") throw() 
    }

    _pushHowling: func {
        state getGlobal(c"package")
        state getField(-1, c"loaded")
        state getField(-1, c"howling")
        /* stack is:
            howling (top)
            loaded
            package
        */
        state replace(-3)
        /* stack:
            loaded (top)
            howling
        */
        state pop(1)
    }

    /** Call a Lua function that expects ooc object(!) arguments.
        Assumes the desired function is on top of the stack.
        No return value will be retrieved.
        This pops the function from the stack.
    */
    callFunction: func (arguments: ...) {
        // duplicate the function.
        state pushValue(-1)
        // push `call_function`
        _pushHowling()
        state getField(-1, "call_function")
        /* stack:
            call_function (top)
            howling
            func
            func
        */
        state replace(-4)
        state pop(1)
        /* stack:
            func (top)
            call_function
            (success!)
        */
        arguments each(|argument|
            state pushLightUserData(argument class)
            state pushLightUserData(argument as Pointer)
        )
        // the function is pushed initially and
        // each ooc argument is pushed as (class, value)
        pcall(arguments count * 2 + 1, 0, "call lua function")
    }
}
