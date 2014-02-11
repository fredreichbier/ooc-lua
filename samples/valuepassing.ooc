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
    binding := Binding new("valuepassing.repo")
    person := Person new("Knuddel")
    binding runFile("valuepassing.lua")

    // call our lua function.
    binding state getGlobal("do_something_with_person")
    binding callFunction(person)
}
