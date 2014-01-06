Person: class {
    name: String

    init: func (=name) {
        
    }

    greet: func {
        "Hello, this is #{name}!" println()
    }

    getName: func -> String {
        name
    }
}

Rucksack: class {
    owner: Person

    init: func (=owner) {
    }

    getOwner: func -> Person {
        owner
    }
}

helloWorld: func {
    "Hello World!" println()
}