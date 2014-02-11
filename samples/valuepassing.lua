local ffi = require "ffi"
local valuepassing = require "valuepassing:valuepassing"

function do_something_with_person (person)
    print("Lua received this person and didn't even cast: " .. tostring(person))
    person:greet()
end
