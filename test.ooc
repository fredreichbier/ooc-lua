import lua.State

main: func {
    state := State new()
    println(state typeName(5))
}
