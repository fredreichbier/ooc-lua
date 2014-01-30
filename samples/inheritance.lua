local inheritance = require "inheritance:inheritance"
local howling = require "howling"

local small = inheritance.House.new("Everywhere")
local big = inheritance.Skyscraper.new("In your backyard", 78)

-- member functions

big:scrape()
-- this is a member function of the super class
big:hello()

small:sayHello(big)

local status, result = pcall(function ()
    return big:functiondoesnotexist()
end)
assert(status == false)

-- members and properties

print("Accessing properties of the parent class:", big.parentProperty)
print("Accessing members of the parent class:", big.address)

big.parentProperty = "Lua value!"

big.address = "this member came from Lua!"
print("Changing members of the parent class:", big.address)

local status, result = pcall(function ()
    return big.doesnotexist
end)
assert(status == false)
