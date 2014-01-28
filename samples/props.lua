local props = require "props:props"
local howling = require "howling"

local heinz = props.Person.new("Heinz")

print("By accessing the struct, we know the name is", heinz.name, howling.from_ooc(heinz.name))
