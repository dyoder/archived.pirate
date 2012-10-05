Crypto = require "crypto"
Buffer = (require "buffer").Buffer

Keys = 
  
  randomKey: (size) -> 
    @bufferToKey @randomBytes size
    
  randomBytes: (size) ->
    Crypto.randomBytes size
  
  numberToKey: (number) ->
    @bufferToKey @numberToBytes number
    
  numberToBytes: (number) ->
    bytes = []
    x = number
    while x >= 256
      bytes.push (x % 256)
      x = Math.floor(x/256)
    bytes.push x
    while bytes.length < 8
      bytes.unshift 0
    new Buffer bytes  
    
  bytesToNumber: (bytes) ->   
    x = 0
    _bytes = []
    for byte in bytes
      _bytes.unshift byte unless byte is 0
    for byte in _bytes
      x *= 256
      x += byte
    x
        
  bytesToBuffer: (bytes) ->
    new Buffer bytes
          
  bufferToKey: (buffer) -> buffer.toString('base64')


module.exports = Keys