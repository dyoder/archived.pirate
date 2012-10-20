{md5} = require "fairmont"

class Connector
  
  constructor: (configuration) ->
    {@transport,@channel,@name,@replyTo,@bus,debug} = configuration
    @bus ?= @transport.bus

  enrich: (message) ->
    unless message instanceof Object
      message = content: message
    message.channel = @channel
    message.id ?= md5 message.content.toString()    
    message.replyTo ?= @replyTo
    message

  end: -> @transport.end()

    
module.exports = Connector