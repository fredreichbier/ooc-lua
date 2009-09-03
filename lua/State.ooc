include lua
include lauxlib

use lua
use math

Types: class {
    none = -1,
    nil = 0,
    boolean = 1,
    lightUserData = 2,
    number = 3,
    string = 4,
    table = 5,
    function = 6,
    userData = 7,
    thread = 8 : static const Int
}

Debug: cover from lua_Debug {
    event: extern Int
    name, what, source: extern const String
    nameWhat: extern(namewhat) Int
    currentLine: extern(currentline) Int
    nUps: extern(nups) Int
    lineDefined: extern(linedefined) Int
    lastLineDefined: extern(lastlinedefined) Int
    shortSrc: extern(short_src) Int//[LUA_IDSIZE]
}

Reg: cover from luaL_Reg {
    name: extern const Char*
    //function: extern(func) extern Func
}

Number: cover from lua_Number
CFunction: cover from lua_CFunction
VAList: cover from va_list
Integer: cover from lua_Integer

State: cover from lua_State* {
    new: static extern(luaL_newstate) func -> This
    close: extern(lua_close) func
    newThread: extern(lua_newthread) func -> State
    atPanic: extern(lua_atpanic) func (panicf: CFunction) -> CFunction
    getTop: extern(lua_gettop) func -> Int
    setTop: extern(lua_settop) func (idx: Int)
    pushValue: extern(lua_pushvalue) func (idx: Int)
    remove: extern(lua_remove) func (idx: Int)
    insert: extern(lua_insert) func (idx: Int)
    replace: extern(lua_replace) func (idx: Int)
    checkStack: extern(lua_checkstack) func (sz: Int) -> Int
    xmove: extern(lua_xmove) func (to: State, n: Int)
    isNumber: extern(lua_isnumber) func (idx: Int) -> Int
    isString: extern(lua_isstring) func (idx: Int) -> Int
    isCFunction: extern(lua_iscfunction) func (idx: Int) -> Int
    isUserData: extern(lua_isuserdata) func (idx: Int) -> Int
    type: extern(lua_type) func (idx: Int) -> Int
    typeName: extern(lua_typename) func (tp: Int) -> Char*
    equal: extern(lua_equal) func (idx1: Int, idx2: Int) -> Int
    rawEqual: extern(lua_rawequal) func (idx1: Int, idx2: Int) -> Int
    lessThan: extern(lua_lessthan) func (idx1: Int, idx2: Int) -> Int
    toNumber: extern(lua_tonumber) func (idx: Int) -> Number
    toInteger: extern(lua_tointeger) func (idx: Int) -> Integer
    toBoolean: extern(lua_toboolean) func (idx: Int) -> Int
    toLString: extern(lua_tolstring) func (idx: Int, len: SizeT*) -> Char*
    objLen: extern(lua_objlen) func (idx: Int) -> SizeT
    toCFunction: extern(lua_tocfunction) func (idx: Int) -> CFunction
    toUserData: extern(lua_touserdata) func (idx: Int) -> Void*
    toThread: extern(lua_tothread) func (idx: Int) -> State
    toPointer: extern(lua_topointer) func (idx: Int) -> Void*
    pushNil: extern(lua_pushnil) func
    pushNumber: extern(lua_pushnumber) func (n: Number)
    pushInteger: extern(lua_pushinteger) func (n: Integer)
    pushLString: extern(lua_pushlstring) func (s: Char*, l: SizeT)
    pushString: extern(lua_pushstring) func (s: Char*)
    pushVFString: extern(lua_pushvfstring) func (fmt: Char*, argp: VAList) -> Char*
    pushFString: extern(lua_pushfstring) func (fmt: Char*) -> Char*
    pushCClosure: extern(lua_pushcclosure) func (fn: CFunction, n: Int)
    pushBoolean: extern(lua_pushboolean) func (b: Int)
    pushLightUserData: extern(lua_pushlightuserdata) func (p: Void*)
    pushThread: extern(lua_pushthread) func -> Int
    getTable: extern(lua_gettable) func (idx: Int)
    getField: extern(lua_getfield) func (idx: Int, k: Char*)
    rawGet: extern(lua_rawget) func (idx: Int)
    rawGetI: extern(lua_rawgeti) func (idx: Int, n: Int)
    createTable: extern(lua_createtable) func (narr: Int, nrec: Int)
    newUserData: extern(lua_newuserdata) func (sz: SizeT) -> Void*
    getMetaTable: extern(lua_getmetatable) func (objindex: Int) -> Int
    getFEnv: extern(lua_getfenv) func (idx: Int)
    setTable: extern(lua_settable) func (idx: Int)
    setField: extern(lua_setfield) func (idx: Int, k: Char*)
    rawSet: extern(lua_rawset) func (idx: Int)
    rawSetI: extern(lua_rawseti) func (idx: Int, n: Int)
    setMetaTable: extern(lua_setmetatable) func (objindex: Int) -> Int
    setFEnv: extern(lua_setfenv) func (idx: Int) -> Int
    call: extern(lua_call) func (nargs: Int, nresults: Int)
    pcall: extern(lua_pcall) func (nargs: Int, nresults: Int, errfunc: Int) -> Int
    cpcall: extern(lua_cpcall) func (function: CFunction, ud: Void*) -> Int
    load: extern(lua_load) func (reader: Func, dt: Void*, chunkname: Char*) -> Int
    dump: extern(lua_dump) func (writer: Func, data: Void*) -> Int
    yield: extern(lua_yield) func (nresults: Int) -> Int
    resume: extern(lua_resume) func (narg: Int) -> Int
    status: extern(lua_status) func -> Int
    gc: extern(lua_gc) func (what: Int, data: Int) -> Int
    error: extern(lua_error) func -> Int
    next: extern(lua_next) func (idx: Int) -> Int
    concat: extern(lua_concat) func (n: Int)
    getAllocF: extern(lua_getallocf) func (ud: Void**) -> Func
    setAllocF: extern(lua_setallocf) func (f: Func, ud: Void*)
    setLevel: extern(lua_setlevel) func (to: State)
    getStack: extern(lua_getstack) func (level: Int, ar: Debug*) -> Int
    getInfo: extern(lua_getinfo) func (what: Char*, ar: Debug*) -> Int
    getLocal: extern(lua_getlocal) func (ar: Debug*, n: Int) -> Char*
    setLocal: extern(lua_setlocal) func (ar: Debug*, n: Int) -> Char*
    getUpValue: extern(lua_getupvalue) func (functionindex: Int, n: Int) -> Char*
    setUpValue: extern(lua_setupvalue) func (functionindex: Int, n: Int) -> Char*
    setHook: extern(lua_sethook) func (function: Func, mask: Int, count: Int) -> Int
    getHook: extern(lua_gethook) func -> Func
    getHookMask: extern(lua_gethookmask) func -> Int
    getHookCount: extern(lua_gethookcount) func -> Int

    /* AUX */
    openLib: extern(luaL_openlib) func (libname: Char*, l: Reg*, nup: Int)
    register: extern(luaL_register) func (libname: Char*, l: Reg*)
    getMetaField: extern(luaL_getmetafield) func (obj: Int, e: Char*) -> Int
    callMeta: extern(luaL_callmeta) func (obj: Int, e: Char*) -> Int
    typError: extern(luaL_typerror) func (narg: Int, tname: Char*) -> Int
    argError: extern(luaL_argerror) func (numarg: Int, extramsg: Char*) -> Int
    checkLString: extern(luaL_checklstring) func (numArg: Int, l: SizeT*) -> Char*
    optLString: extern(luaL_optlstring) func (numArg: Int, def: Char*, l: SizeT*) -> Char*
    checkNumber: extern(luaL_checknumber) func (numArg: Int) -> Number
    optNumber: extern(luaL_optnumber) func (nArg: Int, def: Number) -> Number
    checkInteger: extern(luaL_checkinteger) func (numArg: Int) -> Integer
    optInteger: extern(luaL_optinteger) func (nArg: Int, def: Integer) -> Integer
    checkStack: extern(luaL_checkstack) func ~withMessage (sz: Int, msg: Char*)
    checkType: extern(luaL_checktype) func (narg: Int, t: Int)
    checkAny: extern(luaL_checkany) func (narg: Int)
    newMetaTable: extern(luaL_newmetatable) func (tname: Char*) -> Int
    checkUData: extern(luaL_checkudata) func (ud: Int, tname: Char*) -> Void*
    where: extern(luaL_where) func (lvl: Int)
    error: extern(luaL_error) func ~formatted (fmt: Char*, ...) -> Int
    checkOption: extern(luaL_checkoption) func (narg: Int, def: Char*, lst: Char**) -> Int /* it's Char*[] */
    ref: extern(luaL_ref) func (t: Int) -> Int
    unref: extern(luaL_unref) func (t: Int, ref: Int)
    loadFile: extern(luaL_loadfile) func (filename: Char*) -> Int
    loadBuffer: extern(luaL_loadbuffer) func (buff: Char*, sz: SizeT, name: Char*) -> Int
    loadString: extern(luaL_loadstring) func (s: Char*) -> Int
    gsub: extern(luaL_gsub) func (s: Char*, p: Char*, r: Char*) -> Char*
    findTable: extern(luaL_findtable) func (idx: Int, fname: Char*, szhint: Int) -> Char*
    buffInit: extern(luaL_buffinit) func (b: Buffer)
}

Buffer: cover from luaL_Buffer* {
    prepBuffer: extern(luaL_prepbuffer) func -> Char*
    addLString: extern(luaL_addlstring) func (s: Char*, l: SizeT)
    addString: extern(luaL_addstring) func (s: Char*)
    addValue: extern(luaL_addvalue) func
    pushResult: extern(luaL_pushresult) func
}

