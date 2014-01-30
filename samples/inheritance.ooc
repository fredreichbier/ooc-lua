use luajit

import lua/State
import lua/howling/Binding

House: class {
    address: String
    parentProperty: String {
        get {
            "Works!"
        }
        set(value) {
            "[ooc] setting parentProperty to '#{value}'" println()
        }
    }

    init: func (=address) {}
    hello: func {
        "This is #{class name} at '#{address}'" println()
    }

    sayHello: func (other: House) {
        "I'm saying hello to #{other}" println()
    }

    toString: func -> String {
        "<#{class name}, #{address}>"
    }
}

Skyscraper: class extends House {
    height: SizeT

    init: func (.address, =height) {
        super(address)
    }

    scrape: func {
        "I'm scraping!" println()
    }
}

main: func {
    binding := Binding new("inheritance.repo")
    binding runFile("inheritance.lua")
}
