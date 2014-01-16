[![Build Status](https://travis-ci.org/fredreichbier/ooc-lua.png?branch=master)](https://travis-ci.org/fredreichbier/ooc-lua)

## ooc-lua

A [luajit][luajit] binding for ooc - to load and use Lua code from an ooc program. Since
luajit is API-compatible to [lua][lua], we can just pretend it's a lua binding.

[lua]: http://www.lua.org/
[luajit]: http://www.luajit.org/

### Authors

  * Friedrich Weber
  * Amos Wenger

### Links

  * <http://www.lua.org/>
  * <http://www.luajit.org/>

### FFI notes when embedding

Here are few things to keep in mind while trying to use lua-jit's FFI.

Basically, your problems are going to be that the FFI won't be able to resolve
symbols in your programs. Here's how to expose them on various platforms

#### Linux

On Linux you need to use the linker option `--export-dynamic` - if you're
using the default rock profile (`-pg` - the debug profile), GCC's `-rdynamic`
is already used, which seems to do the trick. Just to make sure, and for it
to work, you can edit `luajit.pc` to have:

```
Libs: -L${libdir} -l${libname} -Wl,--export-dynamic
```

Also, whatever you do, **do not use Ubuntu's luajit packages**. Debian's seem
to work, Ubuntu's are just crashing away, just do yourself a favor and compile
everything you need, by hand, in a clean prefix, cause that's what true scots do.

#### Windows (mingw-w64)

With mingw, you need to use the linker option `--export-all-symbols`. If
you've compiled luajit yourself, you can simply edit `luajit.pc` to have 
a Libs line like this:

```
Libs: -L${libdir} -l${libname} -Wl,--export-all-symbols
```

Also, don't use a luajit build from anywhere - trust only what you build
yourself. A command like this should work:

```
make HOST_CC="gcc -m32" CROSS=i686-w64-mingw32- TARGET_SYS=Windows BUILDMODE=dynamic
```

Contrary to pretty much every other library on earth that cross-compiles cleanly
with mingw, luajit's a special snowflake that:

  1. Gets compiled to lua51.dll - because lua C extensions are linked against that
  name and luajit is a drop-in replacement for lua (the slower, main implementation),
  and so fuck logic.
  2. Doesn't have an equivalent liblua51.dll.a - apparently you can just go ahead and
  link directly with lua51.dll, because MinGW works in mysterious ways.
  3. Doesn't have a clean 'install' target in its Makefile when installing in a cross
  environment. Just copy `src/laux*.h` and `src/lua*.h` to $PREFIX/include, and
  `src/*.dll` to $PREFIX/lib. Also `etc/luajit.pc` to $PREFIX/lib/pkgconfig - but you'll
  need to edit it by hand to change the prefix in there, and also the library name.

Here's a working luajit.pc sample:

```
# Package information for LuaJIT to be used by pkg-config.
majver=2
minver=0
relver=2
version=${majver}.${minver}.${relver}
abiver=5.1

# NOTE - YOU WANT YOUR OWN PREFIX HERE, NOT MINE
prefix=/opt/prefixes/i686-w64-mingw32
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
libname=lua51
includedir=${prefix}/include/luajit-${majver}.${minver}

INSTALL_LMOD=${prefix}/share/lua/${abiver}
INSTALL_CMOD=${prefix}/lib/lua/${abiver}

Name: LuaJIT
Description: Just-in-time compiler for Lua
URL: http://luajit.org
Version: ${version}
Requires:
Libs: -L${libdir} -l${libname} -Wl,--export-all-symbols
Libs.private: -Wl,-E -lm -ldl
Cflags: -I${includedir}
```

#### OSX

If you're building for OSX 64-bit, you need some special compiler flags. You
may want to edit your `luajit.pc` to have a Libs line that looks like this:

```
Libs: -L${libdir} -l${libname} -pagezero_size 10000 -image_base 100000000
```

Otherwise, it'll just crash. On 32-bit, it doesn't to be needed (it's harmful, even!)

Apparently, luajit is doing something funny with its memory allocator and it
won't work when the default (mapping page 0 to the first 4GB of virtual memory)
is applied, apparently.

With that out of the way, OSX doesn't seem to need the `-Wl,--export-dynamic` option
at all. Not sure why. It just works, be happy.

If you need help compiling luajit yourself on OSX, it's always a good idea
to take a look at the [homebrew formula][luajit-brew] for it. It should be self-explanatory,
and if it's not, look up the [Formula cookbook][cookbook].

[luajit-brew]: https://github.com/Homebrew/homebrew/blob/master/Library/Formula/luajit.rb
[cookbook]: https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook

