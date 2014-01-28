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

main: func {
    binding := Binding new("props.repo")
    binding runFile("props.lua")
}
