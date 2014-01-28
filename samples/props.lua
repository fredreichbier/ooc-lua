local props = require "props:props"
local howling = require "howling"

local heinz = props.Person.new("Heinz")

print("We created a person.")
heinz:greet()

print("By accessing the struct, we know the name is", heinz.name)
print("or better:", heinz:get("name"))
print("Enter magical transformation process...")
heinz:set("name", "Wurst")

heinz:greet()
