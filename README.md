[![Build Status](https://travis-ci.org/nddrylliog/ooc-lua.png?branch=master)](https://travis-ci.org/nddrylliog/ooc-lua)

## ooc-lua

A [lua][lua]/[luajit][luajit] binding for ooc - to load and use Lua code from an ooc program.

This ships two usefiles. You can either use `use lua` to link to the original [lua][lua] library
or `use luajit` to link to the API-compatible [luajit][luajit] library.

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
a Cflags line like this:

```
Libs: -L${libdir} -l${libname} -Wl,--export-all-symbols
```

#### OSX

First things first, in luajit.use we have the following linker flags:

```
-pagezero_size 10000 -image_base 100000000
```

Otherwise, it'll just crash. If you use ooc-lua normally you don't need to
worry about that - but luajit is doing something funny with its memory allocator
and it won't work when the default (mapping page 0 to the first 4GB of virtual memory)
is applied, apparently.

With that out of the way, OSX doesn't seem to need the `-Wl,--export-dynamic` option
at all. Not sure why. It just works, be happy.

