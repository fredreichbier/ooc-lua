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
    return mangle_class(module, class) .. func
end

-- Generate a 
function ooc_class(module, class, options)
    -- generate index table
    local index = {}
    for i = 1, #options.functions do
        local name = options.functions[i]
        local mangled = mangle_function(module, class, name)
        index[name] = caller(ffi.C[mangled])
    end
    -- Awesome ffi metatype!
    return ffi.metatype(mangle_class(module, class), {
        __index = index
    })
end

--- Represents an ooc module.
Module = {}
function Module:new (name)
    -- TODO: stolen from the lua tutorial. oh my.
    o = {name = name}
    setmetatable(o, self)
    self.__index = self
    return o
end

--- Load the module, ie. initialize static values.
function Module:load ()
    ffi.C[self.name .. "_load"]()
end

--- Adds a ffi metatype to the module.
function Module:class (name, options)
    local cls = ooc_class(self.name, name, options)
    self[name] = cls
    return cls
end

-- Adds a ffi function.
function Module:func (name)
    local func = caller(ffi.C[mangle_function(self.name, "", name)])
    self[name] = func
    return cls
end

---- Represents a rock lua backend output directory.
--Loader = {}
--function Loader:new (path)
--    -- TODO: Also stolen from the lua tutorial.
--    o = {path = path}
--    setmetatable(o, self)
--    self.__index = self
--    return o
--end
--
---- Load a specific module by its path.
--function Loader:load (module)
--    -- TODO: What to do on windows?
--    -- TODO: Could also use `package.loaders`
--    local filename = self.path .. "/" .. module .. ".lua"
--    return require(filename)
--end
