local props = require "props:props"
local howling = require "howling"

local heinz = props.Person.new("Heinz")

-- try normal attributes
print("[lua] We created a person.")
heinz:greet()

print("[lua] By accessing the struct, we know the name is", heinz.name)
print("[lua] or better:", heinz:get("name"))
print("[lua] Enter magical transformation process...")
heinz:set("name", "Wurst")

heinz:greet()

-- try properties
heinz:set("age", 777)
local new_age = heinz:get("age")
print("[lua] got an age of " .. tostring(new_age))
