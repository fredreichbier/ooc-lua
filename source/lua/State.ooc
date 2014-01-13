
use luajit
include lua
include lauxlib
include lualib

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

Hooks: class {
    call = 0,
    ret = 1,
    line = 2,
    count = 3,
    tailRet = 4: static const Int
}

Lua: class {
    
    versionString: extern(LUA_VERSION) static CString
    release: extern(LUA_RELEASE) static CString
    versionNum: extern(LUA_VERSIONNUM) static Int
    copyright: extern(LUA_COPYRIGHT) static CString
    authors: extern(LUA_AUTHORS) static CString
    signature: extern(LUA_SIGNATURE) static CString
    registryIndex: extern(LUA_REGISTRYINDEX) static Int
    environIndex: extern(LUA_ENVIRONINDEX) static Int

    upvalueIndex: extern(lua_upvalueindex) static func (i: Int) -> Int
    
}

yield: extern(LUA_YIELD) Int
errRun: extern(LUA_ERRRUN) Int
errSyntax: extern(LUA_ERRSYNTAX) Int
errMem: extern(LUA_ERRMEM) Int
errErr: extern(LUA_ERRERR) Int


Debug: cover from lua_Debug {
    idSize: extern(LUA_IDSIZE) static Int
    event: extern Int
    name, what, source, nameWhat: extern const CString
    currentLine: extern(currentline) Int
    nUps: extern(nups) Int
    lineDefined: extern(linedefined) Int
    lastLineDefined: extern(lastlinedefined) Int
    shortSrc: extern(short_src) Char[Debug idSize]
}

Reg: cover from luaL_Reg {
    name: extern const CString
    function: extern(func) extern Func
}

Number: cover from lua_Number extends Double
operator implicit as (d: Double) -> Number { d }
operator implicit as (n: Number) -> Double { n }

CFunction: cover from lua_CFunction
VAList: cover from va_list
Integer: cover from lua_Integer extends Int

State: cover from lua_State* {
    new: static extern(luaL_newstate) func -> This
    new: static extern(lua_newstate) func ~allocator (f: Func, ud: Pointer) -> This
    close: extern(lua_close) func
    newThread: extern(lua_newthread) func -> State
    atPanic: extern(lua_atpanic) func (panicf: CFunction) -> CFunction
    getTop: extern(lua_gettop) func -> Int
    setTop: extern(lua_settop) func (idx: Int)
    pop: extern(lua_pop) func (idx: Int)
    pushValue: extern(lua_pushvalue) func (idx: Int)
    remove: extern(lua_remove) func (idx: Int)
    insert: extern(lua_insert) func (idx: Int)
    replace: extern(lua_replace) func (idx: Int)
    register: extern(lua_register) func (n: Int, f: Func)
    checkStack: extern(lua_checkstack) func (sz: Int) -> Int
    xmove: extern(lua_xmove) func (to: State, n: Int)
    isNumber: extern(lua_isnumber) func (idx: Int) -> Int
    isString: extern(lua_isstring) func (idx: Int) -> Int
    isCFunction: extern(lua_iscfunction) func (idx: Int) -> Int
    isUserData: extern(lua_isuserdata) func (idx: Int) -> Int
    strLen: extern(lua_strlen) func (idx: Int) -> SizeT
    type: extern(lua_type) func (idx: Int) -> Int
    typeName: extern(lua_typename) func (tp: Int) -> CString
    equal: extern(lua_equal) func (idx1: Int, idx2: Int) -> Int
    rawEqual: extern(lua_rawequal) func (idx1: Int, idx2: Int) -> Int
    lessThan: extern(lua_lessthan) func (idx1: Int, idx2: Int) -> Int
    toNumber: extern(lua_tonumber) func (idx: Int) -> Number
    toInteger: extern(lua_tointeger) func (idx: Int) -> Integer
    toBoolean: extern(lua_toboolean) func (idx: Int) -> Int
    toLString: extern(lua_tolstring) func (idx: Int, len: SizeT*) -> CString
    toString: extern(lua_tostring) func (idx: Int) -> CString
    objLen: extern(lua_objlen) func (idx: Int) -> SizeT
    toCFunction: extern(lua_tocfunction) func (idx: Int) -> CFunction
    toUserData: extern(lua_touserdata) func (idx: Int) -> Pointer
    toThread: extern(lua_tothread) func (idx: Int) -> State
    toPointer: extern(lua_topointer) func (idx: Int) -> Pointer
    pushNil: extern(lua_pushnil) func
    pushCFunction: extern(lua_pushcfunction) func (f: Func)
    pushNumber: extern(lua_pushnumber) func (n: Number)
    pushNumber: func ~int (i: Int) { pushNumber(i as Double) }
    pushInteger: extern(lua_pushinteger) func (n: Integer)
    pushLString: extern(lua_pushlstring) func (s: CString, l: SizeT)
    pushString: extern(lua_pushstring) func (s: CString)
    pushVFString: extern(lua_pushvfstring) func (fmt: CString, argp: VAList) -> CString
    pushFString: extern(lua_pushfstring) func (fmt: CString, ...) -> CString
    pushCClosure: extern(lua_pushcclosure) func (fn: CFunction, n: Int)
    pushBoolean: extern(lua_pushboolean) func (b: Int)
    pushLightUserData: extern(lua_pushlightuserdata) func (p: Pointer)
    pushThread: extern(lua_pushthread) func -> Int

    push: func <T> (value: T) {
        match(T) {
            case Int => pushNumber(value as Int)
            case Number => pushNumber(value as Number)
            case Double => pushNumber(value as Double)
            case Bool => pushBoolean(value as Bool ? 1 : 0)
            case String => pushString(value as String toCString())
            case Pointer => {
                if(value as Pointer == null) {
                    pushNil()
                } else {
                    Exception new("Can't push %p as Pointer" format(value as Pointer)) throw()
                }
            }
            case => Exception new("Can't push %s" format(T name)) throw()
        }
    }

    getTable: extern(lua_gettable) func (idx: Int)
    getField: extern(lua_getfield) func (idx: Int, k: CString)
    rawGet: extern(lua_rawget) func (idx: Int)
    rawGetI: extern(lua_rawgeti) func (idx: Int, n: Int)
    createTable: extern(lua_createtable) func (narr: Int, nrec: Int)
    newUserData: extern(lua_newuserdata) func (sz: SizeT) -> Pointer
    getMetaTable: extern(lua_getmetatable) func (objindex: Int) -> Int
    getFEnv: extern(lua_getfenv) func (idx: Int)
    setTable: extern(lua_settable) func (idx: Int)
    setField: extern(lua_setfield) func (idx: Int, k: CString)
    rawSet: extern(lua_rawset) func (idx: Int)
    rawSetI: extern(lua_rawseti) func (idx: Int, n: Int)
    setMetaTable: extern(lua_setmetatable) func (objindex: Int) -> Int
    setFEnv: extern(lua_setfenv) func (idx: Int) -> Int
    call: extern(lua_call) func (nargs: Int, nresults: Int)
    pcall: extern(lua_pcall) func (nargs: Int, nresults: Int, errfunc: Int) -> Int
    cpcall: extern(lua_cpcall) func (function: CFunction, ud: Pointer) -> Int
    load: extern(lua_load) func (reader: Func, dt: Pointer, chunkname: CString) -> Int
    dump: extern(lua_dump) func (writer: Func, data: Pointer) -> Int
    yield: extern(lua_yield) func (nresults: Int) -> Int
    resume: extern(lua_resume) func (narg: Int) -> Int
    status: extern(lua_status) func -> Int
    gc: extern(lua_gc) func (what: Int, data: Int) -> Int
    error: extern(lua_error) func -> Int
    next: extern(lua_next) func (idx: Int) -> Int
    concat: extern(lua_concat) func (n: Int)
    getAllocF: extern(lua_getallocf) func (ud: Pointer*) -> Func
    setAllocF: extern(lua_setallocf) func (f: Func, ud: Pointer)
    setLevel: extern(lua_setlevel) func (to: State)
    getStack: extern(lua_getstack) func (level: Int, ar: Debug*) -> Int
    getInfo: extern(lua_getinfo) func (what: CString, ar: Debug*) -> Int
    getLocal: extern(lua_getlocal) func (ar: Debug*, n: Int) -> CString
    setLocal: extern(lua_setlocal) func (ar: Debug*, n: Int) -> CString
    getUpValue: extern(lua_getupvalue) func (functionindex: Int, n: Int) -> CString
    setUpValue: extern(lua_setupvalue) func (functionindex: Int, n: Int) -> CString
    setHook: extern(lua_sethook) func (function: Func, mask: Int, count: Int) -> Int
    getHook: extern(lua_gethook) func -> Func
    getHookMask: extern(lua_gethookmask) func -> Int
    getHookCount: extern(lua_gethookcount) func -> Int
    newTable: extern(lua_newtable) func
    setGlobal: extern(lua_setglobal) func (name: CString)
    getGlobal: extern(lua_getglobal) func (name: CString)
    isFunction: extern(lua_isfunction) func (n: Int) -> Bool
    isTable: extern(lua_istable) func (n: Int) -> Bool
    isLightUserData: extern(lua_islightuserdata) func (n: Int) -> Bool
    isNil: extern(lua_isnil) func (n: Int) -> Bool
    isBoolean: extern(lua_isboolean) func (n: Int) -> Bool
    isThread: extern(lua_isthread) func (n: Int) -> Bool
    isNone: extern(lua_isnone) func (n: Int) -> Bool
    isNoneOrNil: extern(lua_isnoneornil) func (n: Int) -> Bool

    /* AUX */
    openLib: extern(luaL_openlib) func (libname: CString, l: Reg*, nup: Int)
    registerLib: extern(luaL_register) func (libname: CString, l: Reg*)
    getMetaField: extern(luaL_getmetafield) func (obj: Int, e: CString) -> Int
    callMeta: extern(luaL_callmeta) func (obj: Int, e: CString) -> Int
    typError: extern(luaL_typerror) func (narg: Int, tname: CString) -> Int
    argError: extern(luaL_argerror) func (numarg: Int, extramsg: CString) -> Int
    checkLString: extern(luaL_checklstring) func (numArg: Int, l: SizeT*) -> CString
    optLString: extern(luaL_optlstring) func (numArg: Int, def: CString, l: SizeT*) -> CString
    checkNumber: extern(luaL_checknumber) func (numArg: Int) -> Number
    optNumber: extern(luaL_optnumber) func (nArg: Int, def: Number) -> Number
    checkInteger: extern(luaL_checkinteger) func (numArg: Int) -> Integer
    optInteger: extern(luaL_optinteger) func (nArg: Int, def: Integer) -> Integer
    checkStack: extern(luaL_checkstack) func ~withMessage (sz: Int, msg: CString)
    checkType: extern(luaL_checktype) func (narg: Int, t: Int)
    checkAny: extern(luaL_checkany) func (narg: Int)
    newMetaTable: extern(luaL_newmetatable) func (tname: CString) -> Int
    checkUData: extern(luaL_checkudata) func (ud: Int, tname: CString) -> Pointer
    where: extern(luaL_where) func (lvl: Int)
    error: extern(luaL_error) func ~formatted (fmt: CString, ...) -> Int
    checkOption: extern(luaL_checkoption) func (narg: Int, def: CString, lst: CString*) -> Int /* it's CString[] */
    ref: extern(luaL_ref) func (t: Int) -> Int
    unref: extern(luaL_unref) func (t: Int, ref: Int)
    loadFile: extern(luaL_loadfile) func (filename: const CString) -> Int
    doFile: extern(luaL_dofile) func (filename: const CString) -> Int
    loadBuffer: extern(luaL_loadbuffer) func (buff: CString, sz: SizeT, name: CString) -> Int
    loadString: extern(luaL_loadstring) func (s: CString) -> Int
    gsub: extern(luaL_gsub) func (s: CString, p: CString, r: CString) -> CString
    findTable: extern(luaL_findtable) func (idx: Int, fname: CString, szhint: Int) -> CString
    buffInit: extern(luaL_buffinit) func (b: Buffer)

    /* lualib */
    openBase: extern(luaopen_base) func -> Int
    openTable: extern(luaopen_table) func -> Int
    openIO: extern (luaopen_io) func -> Int
    openOS: extern (luaopen_os) func -> Int
    openString: extern (luaopen_string) func -> Int
    openMath: extern (luaopen_math) func -> Int
    openDebug: extern (luaopen_debug) func -> Int
    openPackage: extern (luaopen_package) func -> Int
    openLibs: extern (luaL_openlibs) func -> Int
}

Buffer: cover from luaL_Buffer* {
    prepBuffer: extern(luaL_prepbuffer) func -> CString
    addLString: extern(luaL_addlstring) func (s: CString, l: SizeT)
    addString: extern(luaL_addstring) func (s: CString)
    addValue: extern(luaL_addvalue) func
    pushResult: extern(luaL_pushresult) func
}

