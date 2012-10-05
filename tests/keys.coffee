Keys = require "../src/keys"

console.log Keys.randomKey 16

# Make sure the numberToBytes function works correctly
x = Date.now()
console.log x
bytes = Keys.numberToBytes x
console.log Keys.bytesToNumber bytes

x = 17
console.log x
bytes = Keys.numberToBytes x
console.log Keys.bytesToNumber bytes

z = Keys.numberToKey Date.now()
console.log z

z = (Keys.bufferToKey (Buffer.concat [Keys.randomBytes(16), (Keys.numberToBytes Date.now())]))
console.log z
console.log (new Buffer z, 'base64').toString('base64')