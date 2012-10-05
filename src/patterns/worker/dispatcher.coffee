Messenger = require "../../channels/messenger"
Queue = require "../../channels/queue"

class Dispatcher
  
  constructor: (configuration) ->

    {@name,@channel,@transport} = configuration

    @from = new Messenger
      channel: "private.#{@name}"
      transport: @transport
      
    @to = new Queue
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
    @to.enqueue message
    
  end: -> 
    @from.end()
    @to.end()

  _listen: ->
    @from.receive (error,reply) =>
      @_process reply

  _process: (message) ->
    callback = @_callbacks[message.id]
    @_callbacks[message.id] = null
    callback(null,message)

  _registerCallback: (id,callback) ->
    @_callbacks[id] = callback
    
module.exports = Dispatcher