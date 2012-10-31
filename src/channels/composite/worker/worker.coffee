Messenger = require "../../messenger"
Queue = require "../../queue"
Channel = require "../../../channel"

class Worker extends Channel
  
  constructor: (configuration) ->
  
    super configuration
  
    @_tasks = new Queue
      name: @name
      transport: @transport
      
    @_messengers = {}
    @_started = false
    @_stopped = false
    
  accept: -> @_run() unless @_started   
    
  _run: ->

    @_started = true

    _run = => @_tasks.dequeue()
    _run()

    @_tasks.bus.on "#{@name}.*.dequeue", (message) =>

      # Grab the channel and id from the message ...
      {replyTo,id} = message

      # listen for the result event ...
      @bus.once "#{@name}.#{id}.result", (result) =>    
        (@_messenger replyTo).send content: result, id: id
        @_tasks.end() if @_stopped

      # ... and generate a 'task' even, passing the message and result
      # function
      @bus.event "#{@name}.#{message.id}.task", message
      
      # check for the next event ...
      process.nextTick _run unless @_stopped
        

  _messenger: (name) ->
    @_messengers[name] ?= new Messenger
      name: name
      transport: @transport
      
  end: -> @_stopped = true
    
      
module.exports = Worker