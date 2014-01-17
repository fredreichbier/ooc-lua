use luajit

import lua/State
import lua/howling/Binding

Person: class {
    name: String

    init: func (=name) {}

    greet: func {
        "Sup? My name is #{name}." println()
    }
}

/* Attention: Dirty hack ahead */
main: func {
    binding := Binding new("lua_repo")
    person := Person new("Knuddel")
    binding runFile("valuepassing.lua")

    // call our lua function.
    binding state getGlobal("do_something_with_person")
    binding state pushNumber(person as UInt64 as Number) // I feel so bad
    binding _checkErrors(binding state pcall(1, 0, binding TRACEBACK_HANDLER_INDEX),
                         "pass pointers around")
}
