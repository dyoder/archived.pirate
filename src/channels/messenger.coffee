Connector = require "../connector"

class Messenger extends Connector
  
  constructor: (configuration) ->
    super configuration
    @channel = "messenger.#{@channel}"
    
  send: (message,callback) ->
    @transport.send (@enrich message), callback

  receive: (callback) ->
    @transport.receive @channel, callback
      
module.exports = Messenger