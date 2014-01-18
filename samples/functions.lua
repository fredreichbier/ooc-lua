local functions = require("functions:functions")

function do_stuff(person, str)
    print("Lua side received the arguments: ", person, str)
    person:greet()
    -- Pass it to ooc again for extra fun
    functions.takePerson(person)
end
