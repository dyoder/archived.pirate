Messenger = require "../../channels/messenger"
Connector = require "../../connector"

class Reply extends Connector
  
  constructor: (configuration) ->

    super configuration
    {@channel} = configuration

    @_to = new Messenger
      channel: "reply.#{@channel}"
      transport: @transport
      
    @_from = new Messenger
      channel: "request.#{@channel}"
      transport: @transport
      
    @_pending = 0
    @_finish = false
    
  reply: (callback) ->
    @_pending++
    @_from.receive (error,message) =>
      @_to.send callback error, message
      @_end() if --@_pending is 0 and @_finish is true
    
  end: -> 
    @_finish = true
    @_end() if @_pending is 0
      
  _end: ->
    @_from.end()
    @_to.end()
        
module.exports = Reply