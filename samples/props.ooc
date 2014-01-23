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

/** return the offset of the `name` field in a Person struct. */
getNameOffset: func -> Int {
    p := Person new("Foo")
    return (((p name&) as Pointer) - (p as Pointer)) as Int
}

main: func {
    binding := Binding new("props.repo")
    binding runFile("props.lua")
}
