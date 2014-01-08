module('howling', package.seeall)

local ffi = require("ffi")

-- Some necessary adjustments
ffi.cdef[[
typedef signed int ssize_t; // TODO: ffi doesn't know ssize_t. But this fix is ... not good.

typedef void* jmp_buf; // TODO: Whatever

struct _FILE;
typedef struct _FILE FILE;

typedef struct {
    size_t length;
    void* data;
} _lang_array__Array;

struct _lang_String__String;
typedef struct _lang_String__String *__s;

struct _lang_types__Closure {
    void *thunk;
    void *context;
};
]]

--- Convert values to their ooc counterpart.
-- Currently, this only converts strings to lang_String__String instances.
function to_ooc(value)
    if type(value) == "string" then
        local converter = ffi.cast("__s(*)(const char *)",
                                    ffi.C.lang_String__String_new_withCStr) -- TODO: oh wow
        return converter(value)
    else
        return value
    end
end

--- Convert ooc values to their lua counterpart.
-- This converts lang_String__String to Lua strings.
function from_ooc(value)
    if value and ffi.istype(String, value) then
        return ffi.string(value:toCString())
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
function mangle_member_function(module, class, func)
    return mangle_class(module, class) .. "_" .. func
end

-- Mangle a function `func` in the module `module`
function mangle_function(module, func)
    return mangle_class(module, "") .. func
end

-- Generate a 
function ooc_class(module, class, options)
    -- generate index table
    local index = options.index or {}
    for i = 1, #options.functions do
        local name = options.functions[i]
        local mangled = mangle_member_function(module, class, name)
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
    local func = caller(ffi.C[mangle_function(self.name, name)])
    self[name] = func
    return cls
end

loader = nil
--- Initialize howling with a lua backend output directory.
function init (path)
    loader = Loader:new(path)
    loader:install()
    local _mod = loader:load("sdk:lang/String")
    _mod.init()
    String = _mod.String
end

local String

-- Represents a rock lua backend output directory.
Loader = {builtin = "builtin", loading = {}}
function Loader:new (path)
    -- TODO: Also stolen from the lua tutorial.
    o = {path = path}
    setmetatable(o, self)
    self.__index = self
    return o
end

--- Load a specific module by its path. See `splitpath`.
-- files in `builtin` take precedence.
-- The path is constructed as follows:
-- "ident:path/to/module.ooc"
-- `ident` is the usefile identifier.
function Loader:load (module, lazy)
    if module:find(":") == nil then
        return nil
    end
    if lazy and self.loading[module] then
        return {lazy = true}
    end
    -- TODO: What to do on windows?
    local rel_filename = "/ooc/" .. module:gsub(":", "/") -- that's pretty evil
    local builtin = loadfile(self.builtin .. rel_filename .. ".lua")
    local loaded
    self.loading[module] = true
    if builtin ~= nil then
        loaded = builtin()
    else
        loaded = require(self.path .. rel_filename) -- TODO: smells like infinity. but currently it works.
    end
    self.loading[module] = false
    return loaded
end

--- Install the loader into package.loaders
function Loader:install()
    table.insert(package.loaders, function (module)
        self:load(module)
    end) -- wat
end

