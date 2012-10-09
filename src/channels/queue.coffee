Connector = require "../connector"

class Queue extends Connector
  
  constructor: (configuration) ->
    super configuration
    {@channel,@replyTo} = configuration
    @channel = "queue.#{@name}"
    
  enqueue: (message,callback) ->
    @transport.enqueue (@enrich message), callback

  dequeue: (callback) ->
    @transport.dequeue @channel, callback
    
module.exports = Queue