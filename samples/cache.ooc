use luajit

import lua/State
import lua/howling/Binding

A: class {
    hello: func {
        "Hello world!" println()
    }
}

B: class extends A {
}

C: class extends B {
}

D: class extends C {
}

E: class extends D {
    init: func {}
}

main: func {
    binding := Binding new("cache.repo")
    binding runFile("cache.lua")
}
