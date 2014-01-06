module('howling', package.seeall)

local ffi = require("ffi")

ffi.cdef[[
struct _lang_String__String;
typedef struct _lang_String__String lang_String__String;

lang_String__String* lang_String__String_new_withCStr(const char *s);
const char *lang_String__String_toCString(lang_String__String* this);
]]

String = ffi.metatype("lang_String__String", {
    __index = {
        --- Return a Lua string from a String object
        tolua = function (this)
            -- TODO: should probably use the stored length!
            return ffi.string(ffi.C.lang_String__String_toCString(this))
        end,

        --- Return a String object from a Lua string value
        create = function (value)
            return ffi.C.lang_String__String_new_withCStr(value)
        end
    }
})

--- Convert values to their ooc counterpart.
-- Currently, this only converts strings to lang_String__String instances.
function to_ooc(value)
    if type(value) == "string" then
        return String.create(value)
    else
        return value
    end
end

--- Convert ooc values to their lua counterpart.
-- This converts lang_String__String to Lua strings.
function from_ooc(value)
    if ffi.istype(String, value) then
        return value:tolua()
    else
        return value
    end
end

--- Call `func`, first calling `to_ooc` on all arguments.
-- And use `from_ooc` on the return value
function call_ooc(func, ...)
    local new_arg = {}
    for i = 1, select("#", ...) do
        new_arg[i] = to_ooc(select(i, ...))
    end
    local result = func(unpack(new_arg))
    return from_ooc(result)
end

--- Return a function that, when called, calls `call_ooc(func, ...)`.
function caller(func)
    return function (...)
        return call_ooc(func, ...)
    end
end

-- Mangle a class `class` in a module `module`.
function mangle_class(module, class)
    return module:gsub("/", "_") .. "__" .. class
end

-- Mangle a member function `func` of a class `class` in the module `module`
function mangle_function(module, class, func)
    return mangle_class(module, class) .. "_" .. func
end

-- Generate a 
function ooc_class(module, class, functions)
    -- generate index table
    local index = {}
    for i = 1, #functions do
        local name = functions[i]
        local mangled = mangle_function(module, class, name)
        index[name] = caller(ffi.C[mangled])
    end
    -- Awesome ffi metatype!
    return ffi.metatype(mangle_class(module, class), {
        __index = index
    })
end

ffi.cdef[[
struct _howling__Person;
typedef struct _howling__Person howling__Person;
struct _howling__PersonClass;
typedef struct _howling__PersonClass howling__PersonClass;

howling__Person* howling__Person_new(lang_String__String* name);
lang_String__String *howling__Person_greet(howling__Person* this, lang_String__String* whom);
lang_String__String *howling__Person_greet_impl(howling__Person* this, lang_String__String* whom);
void howling_load();
]]

Person = ooc_class("howling", "Person", { "new", "greet" })

ffi.C.howling_load()
