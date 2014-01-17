local ffi = require "ffi"
local valuepassing = require "valuepassing:valuepassing"

function do_something_with_person (ptr)
    local person = ffi.cast(valuepassing.Person.symname .. "*", ptr)
    print("Lua received this person: " .. tostring(person))
    person:greet()
end
