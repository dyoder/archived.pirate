class Connector
  
  constructor: (configuration) ->
    {@transport,@logger,debug} = configuration
    @logger ?= @transport.logger
    if debug is true
      @logger.level = true
      @transport.logger.level = true

module.exports = Connector