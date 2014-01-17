_HOWLING_LUA := c"local module = {}

local ffi = require(\"ffi\")

-- Rescue the global variables we need
local assert = assert
local loadfile = loadfile
local table = table
local package = package
local require = require
local setmetatable = setmetatable
local ipairs = ipairs
local select = select
local unpack = unpack
local type = type
local print = print

-- All global variables will be put into `module`.
-- http://lua-users.org/wiki/ModulesTutorial
local module = {}
if setfenv then
	setfenv(1, module) -- for 5.1
else
	_ENV = module -- for 5.2
end

local function prepare()
    -- Some necessary adjustments
    ffi.cdef[[
    typedef signed int ssize_t; // TODO: ffi doesn't know ssize_t. But this fix is ... not good.

    typedef struct jmp_buf jmp_buf; // TODO: Whatever

    typedef struct _FILE FILE;

    typedef struct {
        size_t length;
        void* data;
    } _lang_array__Array;

    struct _lang_String__String;
    typedef struct _lang_String__String *__howling_pointer_to_string; // TODO: Too ugly

    struct _lang_types__Closure {
        void *thunk;
        void *context;
    };
    ]]

--    local closure = ffi.metatype(\"struct _lang_types__Closure\", {
--        __index = {
-- -           symname = \"lang_types__Closure\"
--        }
--    })

    local array = ffi.metatype(\"_lang_array__Array\", {
        __index = {
            symname = \"lang_array__Array\"
        }
    })
end

prepare()

string_converter = nil -- oh wow

--- Convert values to their ooc counterpart.
-- Currently, this only converts strings to lang_String__String instances.
function to_ooc(value)
    if type(value) == \"string\" then
        return string_converter(value)
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
    for i = 1, select(\"#\", ...) do
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

--- Mangle a module, ie. replace special characters with underscores.
function mangle_module(module)
    return module:gsub(\"[/-]\", \"_\")
end

--- Mangle a class `class` in a module `module`.
function mangle_class(module, class)
     return mangle_module(module) .. \"__\" .. class
end

--- Mangle a member function `func` of a class `class` in the module `module`
function mangle_member_function(module, class, func)
    return mangle_class(module, class) .. \"_\" .. func
end

--- Mangle a function `func` in the module `module`
function mangle_function(module, func)
    return mangle_module(module) .. \"__\" .. func
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
    local symname = mangle_class(module, class)
    index[\"symname\"] = symname
    -- Awesome ffi metatype!
    return ffi.metatype(symname, {
        __index = index
    })
end

function import_types(imports)
    for i, module in ipairs(imports) do
        local imported = loader:load_raw(module)
        imported.declare_types()
    end
end

function import_funcs(imports)
    for i, module in ipairs(imports) do
        local imported = loader:load_raw(module)
        imported.declare_and_bind_funcs()
    end
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

--- Load the module, ie. initialize static values. You should only
-- call this once.
function Module:load ()
    local name = mangle_module(self.name) .. \"_load\"
    ffi.cdef(\"void \" .. name .. \"();\");
    ffi.C[name]()
end

--- Initialize the module, ie. declare all types and functions.
function Module:init ()
    self.declare_types()
    self.declare_and_bind_funcs()
--    self:load() -- TODO: only load if we're in a library.
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
    local _mod = loader:load(\"sdk:lang/String\")
    String = _mod.String
    string_converter = ffi.cast(\"__howling_pointer_to_string(*)(const char *)\",
                                ffi.C.lang_String__String_new_withCStr)
end

local String

-- Represents a rock lua backend output directory.
Loader = {}
function Loader:new (path)
    -- TODO: Also stolen from the lua tutorial.
    o = {path = path}
    setmetatable(o, self)
    self.__index = self
    return o
end

--- Load a module and fully initialize it, ie. declare all types and functions
-- and call `load` to initialize static variables.
function Loader:load (module)
    local module = assert(self:load_raw(module))
    module:init()
    return module
end

--- Load a module and add it to `package.loaded`. In case the module
-- couldn't be found, return `(nil, error message)`.
-- This returns a Module object. Attention: This doesn't initialize
-- the module at all (it's raw). You should use `module:init` for that.
function Loader:load_raw (module)
    if package.loaded[module] then
        return package.loaded[module]
    end
    local func, err = self:load_chunk(module)
    if func ~= nil then
        local mod = func()
        package.loaded[module] = mod
        return mod
    else
        return nil, err
    end
end

--- Load the module and return a Lua function that returns a Module instance.
-- Or return (nil, errorcode).
function Loader:load_chunk (module)
    -- TODO: What to do on windows?
    local rel_filename = \"/ooc/\" .. module:gsub(\":\", \"/\") -- that's pretty evil
    local filename = self.path .. rel_filename .. \".lua\"
    -- If the module exists, it must have the filename `filename`.
    local f, errorcode = loadfile(filename)
    if f ~= nil then
        -- It found the module and returned a function.
        return f
    else
        -- It didn't find the module and returned and error code.
        return nil, errorcode
    end
end

--- Install the loader into package.loaders. It will be appended to end.
-- Afterwards, you can just use `require(\"usename:path/to/module\")`, which
-- will return a fully initialized module.
function Loader:install()
    -- This is weird: We insert a function at the end of `package.loaders`
    -- that takes a module path. This is called when Lua searches for a module.
    -- howling then tries to load this module. If the module is found, a unary
    -- function(!) is returned which returns the module.
    -- If it's not found, nil is returned.
    table.insert(package.loaders, function (module)
        local loaded, err = self:load_raw(module)
        -- additional layer of indirection \o/
        if loaded ~= nil then
            return function ()
                loaded:init()
                return loaded
            end
        else
            return \"\\n\t\" .. err
        end
    end)
end

return module
"
