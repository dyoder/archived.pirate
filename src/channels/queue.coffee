Channel = require "../channel"

class Queue extends Channel
  
  constructor: (configuration) ->
    
    super configuration
        
  enqueue: (message) ->
    
    message = @envelope message

    @transport.enqueue message

  dequeue: ->
    
    @transport.dequeue @name
    
module.exports = Queue