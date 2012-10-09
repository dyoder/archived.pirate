Connector = require "../connector"

class Subscription extends Connector
  
  constructor: (configuration) ->
    super configuration
    @channel = "subscription.#{@channel}"
    
  publish: (message,callback) ->
    @transport.publish (@enrich message), callback

  subscribe: (callback) ->
    @_unsubscribe = @transport.subscribe @channel, (error, message) ->
      callback(error, message)
      
  unsubscribe: -> 
    if @_unsubscribe
      @_unsubscribe()
      @_unsubscribe = null
      
module.exports = Subscription