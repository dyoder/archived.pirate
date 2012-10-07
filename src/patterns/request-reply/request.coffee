Messenger = require "../../channels/messenger"

class Request
  
  constructor: (configuration) ->

    {@channel,@transport,@logger} = configuration
    @logger ?= @transport.logger

    @_from = new Messenger
      channel: "reply.#{@channel}"
      transport: @transport
      
    @_to = new Messenger
      channel: "request.#{@channel}"
      transport: @transport
      
    @_counter = 0
    @_callbacks = {}

  request: (message,callback) ->
    if callback
      message.id = @_counter++
      @_registerCallback message.id, callback
      @_listen()
    @_to.send message

  _registerCallback: (id,callback) ->
    @_callbacks[id] = callback
    
  _process: (message) ->
    callback = @_callbacks[message.id]
    @_callbacks[message.id] = null
    callback(null,message)
    
  end: -> 
    @_from.end()
    @_to.end()
  
  _listen: ->
    @_from.receive (error,reply) =>
      # TODO: what do i do with an error here?
      # See ticket #19
      @_process reply
    
module.exports = Request