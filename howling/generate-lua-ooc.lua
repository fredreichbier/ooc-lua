-- call with lua generate-lua-ooc.lua from-lua.lua constant-name
local f = assert(io.open(arg[1], "r"))
local code = f:read("*all"):gsub('"', '\\"'):gsub('\\r', '\\\\r'):gsub('\\n', '\\\\n')
f:close()

print(arg[2] .. ' := c"' .. code .. '"')
