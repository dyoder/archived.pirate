Channel = require "../channel"

# This probably looks a bit strange ... or the Queue class will, depending on
# what you look at first. Because they're identical. Semantically, though,
# they're different things. So I'm keeping them separate for now. At some
# point, I may unify them, they way we did with the Redis Transport.

class Messenger extends Channel
  
  constructor: (configuration) ->
    
    super configuration

  send: (message) ->
    
    message = @envelope message
    
    @transport.send message
    
  receive: ->
    
    @transport.receive @name
      
module.exports = Messenger
