use luajit

import lua/State
import lua/howling/Binding

import deeper_bar

Foo: class {
    bar := Bar new()

    init: func
}

main: func {
    binding := Binding new("deeper.repo")
    binding runFile("deeper.lua")
}
