Messenger = require "../../messenger"
Queue = require "../../queue"
Channel = require "../../../channel"

class Dispatcher extends Channel
  
  constructor: (configuration) ->

    super configuration
    
    @_tasks = new Queue
      name: @name
      transport: @transport
      replyTo: @replyTo
      
    @_results = new Messenger
      name: @replyTo
      transport: @transport

    # Remap receive events on our private channel to result
    # events on the dispatcher channel
    @_results.bus.on "#{@replyTo}.*.receive", (message) =>
      @bus.send "#{@name}.#{message.id}.result", message


  request: (message) ->
    @_tasks.enqueue @envelope message
    @_results.receive()
        
  end: -> 
    @_tasks.end()
    @_results.end()


module.exports = Dispatcher