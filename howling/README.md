howling
=======

howling because, you know, lua, the moon, 3 wolves. yes.

try
---

Fetch my rock [lua-backend](https://github.com/fredreichbier/rock/tree/lua-backend) branch and compile.

Then, to generate Lua binding code:

<pre>
rock --backend=lua test.ooc
</pre>

Most interesting is ``foo/inventory.ooc`` which is wrapped in ``rock_tmp/ooc/test/foo/inventory.lua`` (the path might differ for other people and if it does, it needs to be changed in ``test.lua``).

Then, run

<pre>
rock -v -r test.ooc
</pre>

which imports ``foo/inventory.ooc`` and runs ``test.lua``. Expected output:

<pre>
Lua 5.1
Hello World!
Hello, this is Heinz!
The owner's name is: Heinz
true
Got value: 0.00
</pre>

Super interesting!
