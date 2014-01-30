local deeper = require "deeper:deeper"
-- if this line is commented out, the test fails
-- require "deeper:deeper_bar"
local howling = require "howling"

local foo = deeper.Foo.new()
local bar = foo.bar
local x = bar.x
print("x = " .. x)
assert (x == 42)
