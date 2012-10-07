class Messenger
  
  constructor: (configuration) ->
    {@channel,@transport,@replyTo,@logger} = configuration
    @logger ?= @transport.logger
    @channel = "messenger.#{@channel}"
    
  send: (content,callback) ->
    @transport.send
      channel: @channel
      replyTo: @replyTo
      content: content
      callback

  receive: (callback) ->
    @transport.receive @channel, callback
      
  end: -> @transport.end()
    
module.exports = Messenger