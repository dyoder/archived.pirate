{md5,w} = require "fairmont"
{randomKey} = require "./keys"

class Channel
  
  constructor: (configuration) ->
    {@transport,@name,@replyTo,@bus,@timeout} = configuration
    @timeout ?= 60 * 1000 # 60 seconds in milliseconds
    @replyTo ?= randomKey 16
    @bus ?= @transport.bus
    
  envelope: (message) ->
    unless message instanceof Object
      message = content: message
    message.channel = @name
    # TODO: switch to Redis counter? this is probably faster, but I'm not certain ...
    message.id ?= randomKey 16    
    message.replyTo ?= @replyTo
    message.replyRequested ?= true
    message.timeout ?= @timeout
    message
    
  on: (args...) ->
    @bus.on args...
    
  once: (args...) ->
    @bus.once args...
    
  event: (args...) ->
    @bus.event args...

  end: -> @transport.end()

    
module.exports = Channel