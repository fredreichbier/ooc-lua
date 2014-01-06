local ffi = require("ffi")
local howling = require("howling")

ffi.cdef[[
struct _test__Person;
typedef struct _test__Person test__Person;
struct _test__PersonClass;
typedef struct _test__PersonClass test__PersonClass;

test__Person* test__Person_new(lang_String__String* name);
lang_String__String *test__Person_greet(test__Person* this, lang_String__String* whom);
lang_String__String *test__Person_greet_impl(test__Person* this, lang_String__String* whom);
void test_load();
]]

test = howling.Module:new("test")
test:load()

test:class("Person", {
    functions = {"new", "greet"}
})
local heinz = test.Person.new("Heinz")
local greet = heinz:greet("Hans")

print(greet)
