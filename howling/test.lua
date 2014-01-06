local inventory = require("rock_tmp/ooc/test/foo/inventory")

inventory.helloWorld()

local heinz = inventory.Person.new("Heinz")
heinz:greet()

local rucksack = inventory.Rucksack.new(heinz)
print("The owner's name is: " .. rucksack:getOwner():getName())
print(rucksack:getOwner() == heinz)
