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


