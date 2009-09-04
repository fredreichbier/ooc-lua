import lua.State
import lang.String;

main: func -> Int {
    state := State new()
    state openLibs()
    status := state loadFile("script.lua")
    if(status) {
        state toString(-1) println()
        return 1
    }

    state newTable()
//    for(i in 0..6) {
    i := 1
        state pushNumber(i)
        state pushNumber(i*2)
        state rawSet(-3)
//    }
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
