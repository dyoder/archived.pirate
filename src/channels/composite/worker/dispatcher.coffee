Messenger = require "../../messenger"
PriorityQueue = require "../../priority-queue"
Channel = require "../../../channel"

class Dispatcher extends Channel
  
  constructor: (configuration) ->

    super configuration
    
    {@fireAndForget} = configuration
    @fireAndForget ?= false
    
    @_tasks = new PriorityQueue
      name: @name
      transport: @transport
      replyTo: @replyTo
      
    @_results = new Messenger
      name: @replyTo
      transport: @transport
      
    @_started = false
    @_stopped = false
    @_pending = 0
    @_channels = {}

  request: (message) ->
    message = @envelope message
    @_tasks.enqueue message
    if message.replyRequested
      @_channels[message.id] = @bus.channel message.id


    # The number of keys in the @_channels hash is == pending
    @_pending++

    # Since we add the replyRequested business to the message, we
    # can just check the message. And we can call run just in case
    # in the constructor
    unless @fireAndForget
      @_run() unless @_started
    

  # Default the priority to 1
  envelope: (message) ->
    message = super message
    message.priority ?= 1
    if @fireAndForget
      message.replyRequested = false
    message
    
  _run: ->
    @_started = true

    @_results.receive()

    # Remap receive events on our private channel to result
    # events on the dispatcher channel and check for next event
    @_results.bus.on "receive.message", (message) =>
      @_pending--
      # no reason we can't emit instead of send, since the 
      # message itself is already async
      @_channels[message.id].emit "result", message
      delete @_channels[message.id]
      process.nextTick (=> @_results.receive()) unless @_stopped
      if @_stopped and @_pending is 0
        @_tasks.end()
        @_results.end()

  end: -> 
    @_stopped = true
    
module.exports = Dispatcher