class Queue
  
  constructor: (configuration) ->
    {@channel,@transport,@replyTo} = configuration
    @channel = "queue.#{@name}"
    
  enqueue: (content) ->
    @transport.send
      channel: @channel
      replyTo: @replyTo
      content: content

  dequeue: (callback) ->
    @transport.receive @channel, (error, message) ->
      callback(error, message)
      
  end: -> @transport.end()
    
module.exports = Queue