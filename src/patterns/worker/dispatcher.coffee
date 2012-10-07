Messenger = require "../../channels/messenger"
Queue = require "../../channels/queue"

class Dispatcher
  
  constructor: (configuration) ->

    {@name,@channel,@transport} = configuration

    @_from = new Messenger
      channel: "private.#{@name}"
      transport: @transport
      
    @_to = new Queue
      channel: "request.#{@channel}"
      transport: @transport
      replyTo: "private.#{@name}"
      
    @_counter = 0
    @_callbacks = {}

  request: (message,callback) ->
    if callback
      message.id = @_counter++
      @_registerCallback message.id, callback
      @_listen()
    @_to.enqueue message
    
  end: -> 
    @_from.end()
    @_to.end()

  _listen: ->
    @_from.receive (error,reply) =>
      # TODO: what do i do with an error here?
      # See issues #19, #20.
      @_process reply

  _process: (message) ->
    callback = @_callbacks[message.id]
    @_callbacks[message.id] = null
    callback(null,message)

  _registerCallback: (id,callback) ->
    @_callbacks[id] = callback
    
module.exports = Dispatcher