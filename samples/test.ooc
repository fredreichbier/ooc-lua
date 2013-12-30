use lua
import lua/State

main: func -> Int {
    state := State new()

    Lua versionString println()

    state openLibs()
    status := state loadFile("script.lua")
    if(status) {
        state toString(-1) println()
        return 1
    }

    state newTable()
    for(i: Int in 0..7) {
        state pushNumber(i as Number)
        state pushNumber((i*2) as Number)
        state rawSet(-3)
    }
    state setGlobal("foo")
    result := state pcall(0, -1, 0) /* -1 = LUA_MULTRET */

    if(result) {
        state toString(-1) println()
        return 1
    }
    printf("%.0f\n", state toNumber(-1))
    state pop(1)
    state close()
}
