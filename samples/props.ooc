use luajit

import lua/State
import lua/howling/Binding

Person: class {
    name: String

    age: UInt {
        get {
            "[ooc] getting age! let's return 42." println()
            42
        }
        set(value) {
            "[ooc] setting age to #{value}" println()
        }
    }

    init: func (=name) {}

    greet: func {
        "[ooc] Sup? My name is #{name}." println()
    }


}

main: func {
    binding := Binding new("props.repo")
    binding runFile("props.lua")
}
