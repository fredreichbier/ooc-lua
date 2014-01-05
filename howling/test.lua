local howling = require("howling")

local hai = howling.String.create("Hai")
print("This is a ooc String: " .. tostring(hai))
print("This is a Lua String: " .. hai:tolua())

local heinz = howling.Person.new("Heinz")
heinz:greet("Hans")
