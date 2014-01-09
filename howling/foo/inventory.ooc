import structs/ArrayList

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
    items := ArrayList<Item> new()

    init: func (=owner) {
    }

    getOwner: func -> Person {
        owner
    }

    addItem: func (item: Item) {
        items add(item)
    }

    getItems: func -> ArrayList<Item> {
        items
    }
}

Item: class {
    name: String

    init: func (=name) {
    }
}

helloWorld: func {
    "Hello World!" println()
}

callMeMaybe: func (f: Func (Int) -> Int) -> Int {
    value := f(668)
    "[ooc] Got value #{value} from callback" println()
    value + 1
}
