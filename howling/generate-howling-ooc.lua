local f = assert(io.open("howling.lua", "r"))
local code = f:read("*all"):gsub('"', '\\"')
f:close()

print('_HOWLING_LUA := c"' .. code .. '"')
