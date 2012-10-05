class Messenger
  
  constructor: (configuration) ->
    {@channel,@transport,@replyTo} = configuration
    @channel = "simplex.#{@channel}"
    
  send: (content) ->
    @transport.send
      channel: @channel
      replyTo: @replyTo
      content: content

  receive: (callback) ->
    @isListening = true
    @transport.receive @channel, (error, message) ->
      @isListening = false
      callback(error, message)
      
  isListening: false
      
  end: -> @transport.end()
    
module.exports = Messenger