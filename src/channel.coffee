{md5,w} = require "fairmont"
{randomKey} = require "./keys"

class Channel
  
  constructor: (configuration) ->
    {@transport,@name,@replyTo,@bus,@timeout,debug} = configuration
    @timeout ?= 60 * 1000 # 60 seconds in milliseconds
    @replyTo ?= randomKey 16
    @bus ?= @transport.bus
    if debug 
      Logger = require "./logger"
      logger = new Logger level: "debug"
      levels = w "error warn info debug verbose"
      @bus.receive (event,args...) => 
        [ignored...,level] = event.split "."
        if level in levels
          logger[level] args.join " "
        else
          logger.info "#{event}"

  envelope: (message) ->
    unless message instanceof Object
      message = content: message
    message.channel = @name
    message.id ?= md5 message.content.toString()    
    message.replyTo ?= @replyTo
    message.timeout ?= @timeout
    message
    
  on: (args...) ->
    @bus.on args...

  end: -> @transport.end()

    
module.exports = Channel