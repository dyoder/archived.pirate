Connector = require "../connector"

class Queue extends Connector
  
  constructor: (configuration) ->
    super configuration
    {@channel,@replyTo} = configuration
    @channel = "queue.#{@name}"
    
  enqueue: (content,callback) ->
    @transport.enqueue
      channel: @channel
      replyTo: @replyTo
      content: content
      callback

  dequeue: (callback) ->
    @transport.dequeue @channel, callback
      
  end: -> @transport.end()
    
module.exports = Queue