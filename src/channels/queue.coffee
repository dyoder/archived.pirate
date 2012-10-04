class Queue
  
  constructor: (configuration) ->
    {@name,@transport,@replyTo} = configuration
    
  enqueue: (content) ->
    @transport.send
      channel: @name
      replyTo: @replyTo
      content: content

  dequeue: (callback) ->
    @transport.receive @name, (error, message) ->
      callback(error, message.content)
      
  end: -> @transport.end()
    
module.exports = Queue