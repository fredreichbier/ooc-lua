local howling = require "howling"
local String = require "sdk:lang/String"
local closurehowl = require "closurehowl:closurehowl"
local ffi = require "ffi"

local fnc = howling.make_closure(function (s, n)
    print("Lua is called, got " .. tostring(s) .. " and " .. tostring(n) .. " as values!")
    return 42
end, "int", String.String, "float")

closurehowl.helloWorld(fnc)
