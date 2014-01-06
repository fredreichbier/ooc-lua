use luajit // that's important! ffi is not available when using the ordinary lua.use
import lua/State

import foo/inventory

Person: class {
    name: String

    init: func (=name) {
            
    }

    greet: func (whom: String) -> String {
        "Hello #{whom} from #{name}"
    }
}

main: func -> Int {
    state := State new()

    Lua versionString println()

    state openLibs()
    status := state loadFile("test.lua")
    if(status) {
        state toString(-1) println()
        return 1
    }

    result := state pcall(0, -1, 0) /* -1 = LUA_MULTRET */

    if(result) {
        state toString(-1) println()
        return 1
    }
    "Got value: #{state toNumber(-1)}" println()
    state pop(1)
    state close()
}
