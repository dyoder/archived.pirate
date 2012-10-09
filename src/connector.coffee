class Connector
  
  constructor: (configuration) ->
    {@transport,@logger,debug} = configuration
    @logger ?= @transport.logger
    @logger.level = "debug" if debug is true

  enrich: (message) ->
    if message.charAt
      message = content: message
    message.channel = @channel
    message.replyTo ?= @replyTo
    message

  end: -> @transport.end()

    
module.exports = Connector