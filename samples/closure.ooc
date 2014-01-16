use luajit
import lua/State

add: func (a, b: Double) -> Double {
    a + b
}

addWithThunk: func (state: State) -> Int{
    idx := Lua upvalueIndex(1)
    a := state toNumber(idx)
    b := state toNumber(-1)
    result := add(a, b)
    state push(result)
    return 1 // result is on top of the stack
}

main: func -> Int {
    state := State new()

    Lua versionString println()

    state openLibs()
    status := state loadFile("closure.lua")
    if(status) {
        state toString(-1) println()
        return 1
    }

    state push(1 as Number)
    state pushCClosure(addWithThunk as CFunction, 1)
    state setGlobal("addOne")

    state push(2 as Number)
    state pushCClosure(addWithThunk as CFunction, 1)
    state setGlobal("addTwo")

    result := state pcall(0, -1, 0) /* -1 = LUA_MULTRET */

    if(result) {
        state toString(-1) println()
        return 1
    }
    "Got value: #{state toNumber(-1)}" println()
    state pop(1)
    state close()
}
