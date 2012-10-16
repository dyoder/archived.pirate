class Connector
  
  constructor: (configuration) ->
    {@transport,@channel,@name,@replyTo,@logger,debug} = configuration
    @logger ?= @transport.logger
    @logger.level = "debug" if debug is true
    @logger.name = @name if @name?

  enrich: (message) ->
    unless message instanceof Object
      message = content: message
    message.channel = @channel
    message.replyTo ?= @replyTo
    message

  end: -> @transport.end()

    
module.exports = Connector