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
    @_pending = 0
    
    # Whenever we dequeue a task ...
    @_tasks.bus.on "#{@name}.*.dequeue", (message) =>
      
      # Grab the channel and id from the message ...
      {replyTo,id} = message

      # ... create a function that the worker can use to send the result 
      # to that channel ...    
      result = (result) => 
        @_pending--
        (@_messenger replyTo).send content: result, id: id
        
      # ... and generate a 'task' even, passing the message and result
      # function
      @bus.send "#{@name}.#{message.id}.task", message, result

  accept: ->    
    @_pending++
    @_tasks.dequeue()
    
  _messenger: (name) ->
    @_messengers[name] ?= new Messenger
      name: name
      transport: @transport
      
  end: -> 
    unless @_pending > 0
      @_tasks.end()
      for name,messenger of @_messengers
        messenger.end()
    else
      setTimeout (=>@end()), @timeout
  
      
module.exports = Worker