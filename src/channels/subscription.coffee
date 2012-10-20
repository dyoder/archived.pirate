Channel = require "../channel"

class Subscription extends Channel
  
  constructor: (configuration) ->
    super configuration
    
  publish: (message) ->
    @transport.publish @envelope message

  subscribe: ->
    @_unsubscribe = @transport.subscribe @name
      
  unsubscribe: -> 
    if @_unsubscribe
      @_unsubscribe()
      @_unsubscribe = null
      
module.exports = Subscription