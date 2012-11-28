Messenger = require "../../messenger"
PriorityQueue = require "../../priority-queue"
Channel = require "../../../channel"

class Dispatcher extends Channel
  
  constructor: (configuration) ->

    super configuration
    
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

  request: (message) ->
    @_pending++
    message = @envelope message
    @_tasks.enqueue message
    @_run() unless @_started
    message.id
    

  # Default the priority to 1
  envelope: (message) ->
    message = super message
    message.priority ?= 1
    message
    
  _run: ->
    @_started = true
    _run = => @_results.receive()
    _run()

    # Remap receive events on our private channel to result
    # events on the dispatcher channel and check for next event
    @_results.bus.on "#{@replyTo}.*.receive", (message) =>
      @_pending--
      @bus.event "#{@name}.#{message.id}.result", message
      process.nextTick _run unless @_stopped
      if @_stopped and @_pending is 0
        @_tasks.end()
        @_results.end()

  end: -> 
    @_stopped = true
    
module.exports = Dispatcher