local howling = require("howling")
howling.init("rock_tmp")

local inventory = howling.loader:load("test:foo/inventory")

inventory.helloWorld()

local heinz = inventory.Person.new("Heinz")
heinz:greet()

local rucksack = inventory.Rucksack.new(heinz)
print("The owner's name is: " .. rucksack:getOwner():getName())

local toothbrush = inventory.Item.new("Toothbrush")
rucksack:addItem(toothbrush)

local pickaxe = inventory.Item.new("Pickaxe")
rucksack:addItem(pickaxe)

print(string.format("We have %d items!", tonumber(rucksack:getItems():getSize())))
