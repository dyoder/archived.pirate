Messenger = require "../../messenger"
PriorityQueue = require "../../priority-queue"
Channel = require "../../../channel"

class Worker extends Channel
  
  constructor: (configuration) ->
  
    super configuration
    
    {@interval} = configuration
    @interval ?= 0
    
    @_tasks = new PriorityQueue
      name: @name
      transport: @transport
      
    @_messengers = {}
    @_started = false
    @_stopped = false
    
  accept: -> @_run() unless @_started   
    
  _run: ->

    @_started = true

    _run = => @_tasks.dequeue()
    ch = _run()

    @_tasks.bus.on "#{@name}.message", (message) =>

      # Grab the channel and id from the message ...
      {replyRequested,replyTo,id} = message

      if replyRequested
        # listen for the result event ...
        # TODO: this will create a memory leak if there's no response
        ch "result", (result) =>    
          (@_messenger replyTo).send content: result, id: id
          # TODO: what if there several outstanding listeners like this?
          @_tasks.end() if @_stopped

      # ... and generate a 'task' even, passing the message and result
      # function
      @bus.event "#{@name}.#{message.id}.task", message
      
      # check for the next event ...
      (setTimeout _run, @interval) unless @_stopped
        

  _messenger: (name) ->
    @_messengers[name] ?= new Messenger
      name: name
      transport: @transport
      
  end: -> @_stopped = true
    
      
module.exports = Worker