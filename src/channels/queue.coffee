Connector = require "../connector"

class Queue extends Connector
  
  constructor: (configuration) ->
    super configuration
    @channel = "queue.#{@channel}"
    
  enqueue: (message,callback) ->
    @transport.enqueue (@enrich message), callback

  dequeue: (callback) ->
    @transport.dequeue @channel, callback
    
module.exports = Queue