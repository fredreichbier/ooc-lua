_HOWLING_LUA := c"local module = {}

local ffi = require(\"ffi\")

-- Rescue the global variables we need
local assert = assert
local loadfile = loadfile
local table = table
local package = package
local require = require
local tonumber = tonumber
local setmetatable = setmetatable
local ipairs = ipairs
local select = select
local unpack = unpack
local tostring = tostring
local type = type
local print = print
local error = error

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

    // Predefine an unrolled class struct. I assume this won't change much.
    struct __howling_predef_Class {
        void* class;
        size_t instanceSize;
        size_t size;
        struct _lang_String__String* name;
        struct __howling_predef_Class* super;
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

local String
local class_table = {} -- table connecting class pointers (Class*) to types
local string_converter = nil -- oh wow
loader = nil

function to_ctype(typedecl)
    if type(typedecl) == \"string\" then
        return ffi.typeof(typedecl)
    elseif type(typedecl) == \"cdata\" and typedecl[\"is_class\"] then
        -- Classes are usually passed by reference.
        return ffi.typeof(\"$*\", typedecl)
    else
        return typedecl
    end
end

--- Convenience shortcut for ffi.cast.
-- You can use this to easily downcast ooc objects. Example:
--   ffi.cast(ffi.typeof(\"$*\", MyClass), myObject)
-- simplifies to:
--   howling.cast(MyClass, myObject)
function cast(typedecl, value)
    if type(typedecl) == \"string\" then
        return ffi.cast(typedecl, value)
    else
        return ffi.cast(to_ctype(typedecl), value)
    end
end

--- Make a closure and return it.
-- Currently only closures without context are supported. You got to
-- pass the return type and all argument types, either as strings
-- or ctype instances.
-- There is a special case when passing class types: In reality,
-- a class like `String` is defined as a metatype on the String *struct*,
-- not a pointer to the struct. So you would have to pass class types
-- as \"lang_String__String*\" or ffi.typeof(\"$*\", String.String). Because
-- I bet you'll never pass classes by-value, you can just pass the metatype
-- as a type and howling converts it to a pointer to that type internally.
function make_closure(func, returntype, ...)
    -- first, construct a function type template using parameterized types
    -- and ctypeize the return type and parameter types
    local parameterdollars = {}
    local parameters = { to_ctype(returntype) }
    for i = 1, select(\"#\", ...) do
        table.insert(parameterdollars, \"$\")
        table.insert(parameters, to_ctype(select(i, ...)))
    end
    local template = \"$(*)(\" .. table.concat(parameterdollars, \", \") .. \")\"
    local functype = ffi.typeof(template, unpack(parameters))
    -- we now have a function ctype, create a Closure object now.
    local closure = ffi.new(\"lang_types__Closure\")
    closure.thunk = ffi.cast(functype, lua_called(func))
    closure.context = nil
    return closure
end

--- Internally call a Lua function with ooc parameters.
-- First argument is the Lua function, remaining arguments
-- are pairs of (class pointer, value pointer), both are numbers and
-- will be casted accordingly.
function call_function(func, ...)
    arguments = {}
    for i = 1, select(\"#\", ...)/2 do
        local class_ptr = ffi.cast(\"uintptr_t\", select(i * 2 - 1, ...))
        local raw_value = select(i * 2, ...)
        local typ_ = class_table[tostring(class_ptr)]
        if typ_ == nil then
            error(\"Unknown type: \" .. tostring(class_ptr))
        end
        -- So we now have the ctype in `typ_` and we can cast accordingly.
        -- This particular way only works for class types, obviously.
        local ptr_type = ffi.typeof(\"$*\", typ_)
        local casted_value = from_ooc(ffi.cast(ptr_type, raw_value))
        arguments[#arguments + 1] = casted_value
    end
    return func(unpack(arguments))
end

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

--- Call `func`, first calling `from_ooc` on all arguments.
-- And use `to_ooc` on the return value
-- This is useful for callbacks.
function call_lua(func, ...)
    local new_arg = {}
    for i = 1, select(\"#\", ...) do
        new_arg[i] = from_ooc(select(i, ...))
    end
    local result = func(unpack(new_arg))
    return to_ooc(result)
end

--- Return a function that, when called, calls `call_lua(func, ...)`.
function lua_called(func)
    return function (...)
        return call_lua(func, ...)
    end
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

function get_setter_name (key)
    return \"__set\" .. key .. \"__\"
end

function get_getter_name (key)
    return \"__get\" .. key .. \"__\"
end

--- Generate a ffi metatype for the desired class and return it.
-- `options` is a table and can contain `index`, which will
-- be used as the base for the __index table if present.
-- Also, it must contain `functions`, a table of member function names,
-- and `properties`, a table of property names.
-- This also adds `get` and `set` methods for member/property access.
function ooc_class(module, class, options)
    -- generate index table
    local index_table = options.index or {}
    -- functions
    for i = 1, #options.functions do
        local name = options.functions[i]
        local mangled = mangle_member_function(module, class, name)
        index_table[name] = caller(ffi.C[mangled])
    end
    -- construct properties and members table
    -- mapping the name to \"member\" or \"property\"
    local members_set = {}
    for i = 1, #options.properties do
        members_set[options.properties[i]] = \"property\"
    end
    for i = 1, #options.members do
        members_set[options.members[i]] = \"member\"
    end
    -- other handy stuff
    local symname = mangle_class(module, class)
    index_table[\"symname\"] = symname
    index_table[\"is_class\"] = true
    index_table[\"index_table\"] = index_table
    -- Awesome ffi metatype!
    local typ_ = ffi.metatype(symname, {
        __index = function (self, value)
            -- TODO: This is here to detect that something is wrong early.
            assert(value ~= \"_values\")
            -- Check the index table (cache) first
            local cached = index_table[value]
            if cached ~= nil then
                return cached
            end
            -- Then, check for members
            local kind = members_set[value]
            if kind ~= nil then
                if kind == \"property\" then
                    return self[get_getter_name(value)](self)
                elseif kind == \"member\" then
                    return from_ooc(self._values[value])
                else
                    error(\"unknown kind: \" .. tostring(kind))
                end
            elseif self.symname == \"lang_types__Object\" then
                error((\"function/member '%s' is nowhere to be found\"):format(value))
            else
                -- well, are we trying to access a static member or a non-static member?
                if self == ffi.typeof(self) then -- static function. TODO: better check?
                    -- Ask our supertype directly, no cast needed.
                    -- But we can still cache it!
                    local superval = self.superclass[value]
                    -- TODO: Since static members work totally differently, this only
                    -- works for static member functions anyway.
                    if type(superval) == \"function\" then
                        index_table[value] = superval
                    end
                    return superval
                else
                    -- ask the superclass
                    local superval = self._values.__super__[value]
                    if type(superval) == \"function\" then
                        local supertype = ffi.typeof(self._values.__super__)
                        -- We have to inject a function that casts our `this` argument
                        -- to the correct type. If we're calling a method of the Base
                        -- class on a Derived object, the argument type has to be Base*,
                        -- not Derived*.
                        local casted = function (this, ...)
                            return superval(ffi.cast(supertype, this), ...)
                        end
                        -- Add the casted function to the index table to avoid lookups
                        -- and casts every time it's called.
                        index_table[value] = casted
                        return casted
                    else
                        return superval
                    end
                end
            end
        end,
        __newindex = function (self, key, value)
            -- set a property or a member
            local kind = members_set[key]
            if kind == \"property\" then
                self[get_setter_name(key)](self, value)
            elseif kind == \"member\" then
                self._values[key] = to_ooc(value)
            elseif self.symname == \"lang_types__Object\" then
                error((\"Couldn't set value. Unknown key: '%s'\"):format(key))
            else
                -- try the superclass
                self._values.__super__[key] = value
            end
        end
    })
    -- add it to the class table
    -- Call the _class function directly to get the class pointer
    local class_function = symname .. \"_class\"
    ffi.cdef(\"uintptr_t \" .. class_function .. \"();\") -- apparently, uintptr_t exists.
    local class_pointer = ffi.C[class_function]()
    -- Store the pointer as a string, because it might not fit into the Lua doubles.
    class_table[tostring(class_pointer)] = typ_
    -- Now, we can even determine the superclass!
    local class_struct = ffi.cast(\"struct __howling_predef_Class*\", class_pointer)
    local super_pointer = ffi.cast(\"uintptr_t\", class_struct.super)
    -- We assume the superclass has already been added to the classtable.
    index_table[\"superclass\"] = class_table[tostring(super_pointer)]
    return typ_
end

--- Generate table with info re: desired enum and return it
-- `options` is a table and contains `values`, a list of the enums' values
-- and their C symbols
function ooc_enum(module, enum, options)
    -- generate index table
    local index = {}

    -- symbol name - we need that to get the value struct
    local symname = mangle_class(module, enum)
    index[\"symname\"] = symname

    -- construct values tables
    for i = 1, #options.values do
        local name = options.values[i]
        index[name] = ffi.C[symname .. \"__values\"][name]
    end

    return index
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

function import_classes(imports)
    for i, module in ipairs(imports) do
        local imported = loader:load_raw(module)
        imported.declare_classes()
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

--- Initialize the module, ie. declare all types, functions and classes.
-- This can be called multiple times without problems (subsequent
-- calls just don't do anything)
function Module:init ()
    self.declare_types()
    self.declare_and_bind_funcs()
    self.declare_classes()
    self:import_loose_classes()
--    self:load() -- TODO: only load if we're in a library.
end

-- Recursively handle loose imports and call `declare_classes` on them.
function Module:import_loose_classes()
    if self._imported_loose then return end
    self._imported_loose = true
    for i, name in ipairs(self._loose_imports) do
        local imported = loader:load_raw(name)
        imported.declare_classes()
        imported:import_loose_classes()
    end
end

--- Adds a ffi metatype to the module.
function Module:class (name, options)
    local cls = ooc_class(self.name, name, options)
    self[name] = cls
    return cls
end

-- Adds a ffi enum to the module
function Module:enum (name, options)
    local enum = ooc_enum(self.name, name, options)
    self[name] = enum
    return enum
end

-- Adds a ffi function.
function Module:func (name)
    local func = caller(ffi.C[mangle_function(self.name, name)])
    self[name] = func
    return cls
end

--- Initialize howling with a lua backend output directory.
-- Afterwards, you can access `howling.loader`.
function init (path)
    loader = Loader:new(path)
    loader:install()
    local _mod = loader:load(\"sdk:lang/String\")
    String = _mod.String
    string_converter = ffi.cast(\"__howling_pointer_to_string(*)(const char *)\",
                                ffi.C.lang_String__String_new_withCStr)
end

-- Represents a rock lua backend output directory.
Loader = {}
function Loader:new (path)
    -- TODO: Also stolen from the lua tutorial.
    o = {path = path, cache = {}}
    setmetatable(o, self)
    self.__index = self
    return o
end

--- Load a module and fully initialize it.
-- That means: declare all types and functions.
function Loader:load (module)
    local module = assert(self:load_raw(module))
    module:init()
    return module
end

--- Load a module and add it to `package.loaded`.
-- In case the module couldn't be found, return `(nil, error message)`.
-- This returns a Module object. Attention: This doesn't initialize
-- the module at all (it's raw). You should use `module:init` for that.
-- This uses `self:cache` as a package.loaded-like module cache.
function Loader:load_raw (module)
    if self.cache[module] then
        return self.cache[module]
    end
    local func, err = self:load_chunk(module)
    if func ~= nil then
        local mod = func()
        self.cache[module] = mod
        return mod
    else
        return nil, err
    end
end

--- Load the module and return a Lua function that returns a Module instance.
-- Or return (nil, errorcode) if the module couldn't be found.
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
        -- additional layer of indirection
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
