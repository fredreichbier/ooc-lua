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

ffi.cdef[[
struct _howling__Person;
typedef struct _howling__Person howling__Person;
struct _howling__PersonClass;
typedef struct _howling__PersonClass howling__PersonClass;

howling__Person* howling__Person_new(lang_String__String* name);
void howling__Person_greet(howling__Person* this, lang_String__String* whom);
void howling__Person_greet_impl(howling__Person* this, lang_String__String* whom);
void howling_load();
]]

Person = ffi.metatype("howling__Person", {
    __index = {
        new = function (name)
            return from_ooc(ffi.C.howling__Person_new(to_ooc(name)))
        end,

        greet = function (this, whom)
            return from_ooc(ffi.C.howling__Person_greet(this, to_ooc(whom)))
        end
    }
})

ffi.C.howling_load()
