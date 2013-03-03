# Just double-checking that deleting from an object doesn't delete other
# references to the object

h = {}

h["foo"] = { baz: 5}
h["bar"] = { baz: 7}

x = h["foo"]

delete h["foo"]

console.log h
console.log x