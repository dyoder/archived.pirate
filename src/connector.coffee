class Connector
  
  constructor: (configuration) ->
    {@transport,@logger,debug} = configuration
    @logger ?= @transport.logger

module.exports = Connector