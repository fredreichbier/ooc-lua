use luajit

import lua/State
import lua/howling/Binding

helloWorld: func (x: Func (String, Float) -> Int) {
    "Hello from ooc land! Number is #{x("sup", 3.14)}" println()
}

main: func {
    binding := Binding new("closurehowl.repo")
    binding runFile("closurehowl.lua")
}
