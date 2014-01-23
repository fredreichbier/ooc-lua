local props = require "props:props"
local heinz = props.Person.new("Heinz")
local ffi = require "ffi"

local offset = props.getNameOffset()
print("Offset is:", offset)

-- get the name by pointer magic
local String = require "sdk:lang/String"
local howling = require "howling"
-- Now, we get a String**, because we just add the address of
-- the Person struct and the offset of the String* name member.
local name_ptr = ffi.cast(ffi.typeof("$**", String.String),
                ffi.cast("uintptr_t", heinz) +
                ffi.cast("uintptr_t", offset)
            )
print("Name is", name_ptr[0], howling.from_ooc(name_ptr[0]))
