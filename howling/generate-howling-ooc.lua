local f = assert(io.open("howling.lua", "r"))
local code = f:read("*all"):gsub('"', '\\"'):gsub('\\r', '\\\\r'):gsub('\\n', '\\\\n')
f:close()

print('_HOWLING_LUA := c"' .. code .. '"')
