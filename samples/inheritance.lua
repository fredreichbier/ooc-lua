local inheritance = require "inheritance:inheritance"
local howling = require "howling"

local big = inheritance.Skyscraper.new("In your backyard", 78)

-- member functions

big:scrape()
-- this is a member function of the super class
big:hello()

local status, result = pcall(function ()
    return big:functiondoesnotexist()
end)
assert(status == false)

-- members and properties

print("Accessing properties of the parent class:", big:get("parentProperty"))
print("Accessing members of the parent class:", big:get("address"))

big:set("parentProperty", "Lua value!")

big:set("address", "this member came from Lua!")
print("Changing members of the parent class:", big:get("address"))

local status, result = pcall(function ()
    return big:get("doesnotexist")
end)
assert(status == false)
