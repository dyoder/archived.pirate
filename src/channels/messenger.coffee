Connector = require "../connector"

class Messenger extends Connector
  
  constructor: (configuration) ->
    super configuration
    {@channel,@replyTo} = configuration
    @channel = "messenger.#{@channel}"
    
  send: (content,callback) ->
    @logger.info "Sending message: #{content[0..15]} ..."
    @transport.send
      channel: @channel
      replyTo: @replyTo
      content: content
      callback

  receive: (callback) ->
    @transport.receive @channel, callback
      
  end: -> @transport.end()
    
module.exports = Messenger