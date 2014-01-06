local howling = require("howling")

local heinz = howling.howling.Person.new("Heinz")
local greet = heinz:greet("Hans")

print(greet)
