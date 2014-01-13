howling = require "howling"
howling.init "rock_tmp"

inventory = howling.loader\load "test:foo/inventory"
inventory.helloWorld!

heinz = inventory.Person.new "Heinz"
heinz\greet!

rucksack = inventory.Rucksack.new heinz
print "The owner's name is: #{ rucksack\getOwner!\getName! }"

toothbrush = inventory.Item.new "Toothbrush"
rucksack\addItem toothbrush

pickaxe = inventory.Item.new "Pickaxe"
rucksack\addItem pickaxe

print "We have #{ tonumber rucksack\getItems!\getSize! } items!"

