Crypto = require "crypto"
Buffer = (require "buffer").Buffer

Keys = 
  
  randomKey: (size) -> 
    @bufferToKey @randomBytes size
    
  randomBytes: (size) ->
    Crypto.randomBytes size
  
  numberToKey: (number) ->
    @bufferToKey @numberToBytes number
    

  # We don't use, say, writeDoubleBE because I'm leery about hard-coding the
  # size of a double, given that buffers deal in raw memory. The worst that
  # happens in the code below is that we "truncate" a 16-byte value someday. I
  # was also getting trailing 0s but that might have been because I was using BE
  # instead of LE ... ? Also, we don't use bitwise operators here because
  # JavaScript auto-converts values to 32-bits when you do that.        
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
    
  # This function is primarily here to make it easy to test the numberToBytes
  # function. The Buffer object works just like an array so you can pass in
  # either a Buffer instance or an array here.  
  bytesToNumber: (bytes) ->   
    x = 0
    _bytes = []
    for byte in bytes
      _bytes.unshift byte unless byte is 0
    for byte in _bytes
      x *= 256
      x += byte
    x
        
  bufferToKey: (buffer) -> buffer.toString('base64')


module.exports = Keys