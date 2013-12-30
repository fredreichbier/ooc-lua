-- closure.lua
-- Receives a closure, calls it with a few different values

io.write("The table the script received has:\n");
x = 0
print("At first, x is :", x)
x = addOne(x)
print("After adding one, x is :", x)
x = addTwo(x)
print("After adding two, x is: ", x)
io.write("Returning data back to C\n");
return x

