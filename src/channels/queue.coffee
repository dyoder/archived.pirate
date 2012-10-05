class Queue
  
  constructor: (configuration) ->
    {@channel,@transport,@replyTo} = configuration
    @channel = "queue.#{@name}"
    
  enqueue: (content) ->
    @transport.enqueue
      channel: @channel
      replyTo: @replyTo
      content: content

  dequeue: (callback) ->
    @transport.dequeue @channel, (error, message) ->
      callback(error, message)
      
  end: -> @transport.end()
    
module.exports = Queue