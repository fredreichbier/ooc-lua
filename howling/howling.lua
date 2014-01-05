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
            return ffi.C.howling__Person_new(String.create(name))
        end,

        greet = function (this, whom)
            return ffi.C.howling__Person_greet(this, String.create(whom))
        end
    }
})

ffi.C.howling_load()
