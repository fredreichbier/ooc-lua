all: source/lua/howling/_howling.ooc

source/lua/howling/_howling.ooc: howling/howling.lua
	(cd howling; lua generate-lua-ooc.lua howling.lua _HOWLING_LUA > ../$@)

clean:
	rm -f source/lua/howling/_howling.ooc

.PHONY: clean
