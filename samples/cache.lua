local cache = require("cache:cache")
local e = cache.E.new()

-- It doesn't know it yet!
assert(rawget(e.index_table, "hello") == nil)
e:hello()
-- It does know it now!
assert(rawget(e.index_table, "hello") ~= nil)
e:hello()
e:hello()
e:hello()

-- It doesn't know it yet!
assert(rawget(e.index_table, "staticYo") == nil)
cache.E.staticYo()
-- Now it does!
assert(rawget(e.index_table, "staticYo") ~= nil)
cache.E.staticYo()
cache.E.staticYo()
cache.E.staticYo()

local status, result = pcall(function ()
    return cache.E.iDontExist()
end)
assert(status == false)
