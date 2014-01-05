-- oocffi.lua
-- Create and use an ooc object from lua

local ffi = require("ffi")
ffi.cdef[[
struct _oocffi__Person;
typedef struct _oocffi__Person oocffi__Person;
struct _oocffi__PersonClass;
typedef struct _oocffi__PersonClass oocffi__PersonClass;

struct _lang_String__String;
typedef struct _lang_String__String lang_String__String;

lang_String__String* lang_String__String_new_withCStr(const char *s);
oocffi__Person* oocffi__Person_new(lang_String__String* name);
void oocffi__Person_init(oocffi__Person* this, lang_String__String* name);
void oocffi__Person_greet(oocffi__Person* this, lang_String__String* whom);
void oocffi__Person_greet_impl(oocffi__Person* this, lang_String__String* whom);
void oocffi__Person___defaults__(oocffi__Person* this);
void oocffi__Person___defaults___impl(oocffi__Person* this);
void oocffi__Person___load__();
void oocffi_load();
]]
-- "Heinz"
local heinzS = ffi.C.lang_String__String_new_withCStr("Heinz")
-- heinz := Person new("Heinz")
local heinz = ffi.C.oocffi__Person_new(heinzS)
-- "Karl"
local karlS = ffi.C.lang_String__String_new_withCStr("Karl")
-- heinz greet("Karl")
ffi.C.oocffi__Person_greet(heinz, karlS)

return 1337
