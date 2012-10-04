Queue = require "./channels/queue"

class Messenger
  
  constructor: (@name,@transport) ->
    
  queue: (name) ->
    new Queue
      name: name
      transport: @transport
      replyTo: @name
  

module.exports = Messenger