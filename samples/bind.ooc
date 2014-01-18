use luajit

import lua/State
import lua/howling/Binding

helloWorld: func {
    "Hello from ooc land!" println()
}

main: func {
    binding := Binding new("bind.repo")
    binding runString("local bind = require(\"bind:bind\")
                       bind.helloWorld()")
}
