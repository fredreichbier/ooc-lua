local howling = require("howling")
howling.init("rock_tmp")

local inventory = howling.loader:load("test:foo/inventory")
inventory.init()

inventory.helloWorld()

local heinz = inventory.Person.new("Heinz")
heinz:greet()

local rucksack = inventory.Rucksack.new(heinz)
print("The owner's name is: " .. rucksack:getOwner():getName())
print(rucksack:getOwner() == heinz)

local ffi = require("ffi")

local callback = ffi.cast("int(*)(int)", function (value)
    print("[lua] Callback called with " .. value)
    return value * 2
end)

local closure = ffi.new("lang_types__Closure", { thunk = callback, context = nil })

print("[lua] callMeMaybe returned with " .. inventory.callMeMaybe(closure))
