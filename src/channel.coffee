{md5} = require "fairmont"
{randomKey} = require "./keys"

class Channel
  
  constructor: (configuration) ->
    {@transport,@name,@replyTo,@bus,@timeout,debug} = configuration
    @timeout ?= 60 * 1000 # 60 seconds in milliseconds
    @replyTo ?= randomKey 16
    @bus ?= @transport.bus

  envelope: (message) ->
    unless message instanceof Object
      message = content: message
    message.channel = @name
    message.id ?= md5 message.content.toString()    
    message.replyTo ?= @replyTo
    message.timeout ?= @timeout
    message

  end: -> @transport.end()

    
module.exports = Channel