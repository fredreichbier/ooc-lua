local howling = require("howling")
howling.init("rock_tmp")
local inventory = require("test:foo/inventorys")
inventory.helloWorld()
local heinz = inventory.Person.new("Heinz")
heinz:greet()
local rucksack = inventory.Rucksack.new(heinz)
print("The owner's name is: " .. tostring(rucksack:getOwner():getName()))
local toothbrush = inventory.Item.new("Toothbrush")
rucksack:addItem(toothbrush)
local pickaxe = inventory.Item.new("Pickaxe")
rucksack:addItem(pickaxe)
return print("We have " .. tostring(tonumber(rucksack:getItems():getSize())) .. " items!")
