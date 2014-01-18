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

hans := Person new("Hans Wurst")

takePerson: func (person: Person) {
    "ooc side received this object: #{person as Pointer}" println()
    if(person == hans) {
        "And it's Hans! Thank you, Lua!" println()
    } else {
        "But it's not Hans. Something went wrong. :(" println()
        exit(1)
    }
}

main: func {
    binding := Binding new("lua_repo")
    binding runFile("functions.lua")
    binding state getGlobal("do_stuff")
    binding callFunction(hans, "Hello World")
}
