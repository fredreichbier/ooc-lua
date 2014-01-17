use luajit

import lua/State
import lua/howling/Binding

helloWorld: func {
    "Hello from ooc land!" println()
}

main: func {
    binding := Binding new("lua_repo")
    binding runString("--local bind = require(\"bind:bind\")
                       local howling = require(\"howling\")
                       local bind = require(\"bind:bind\")
                       bind.helloWorld()")
}
