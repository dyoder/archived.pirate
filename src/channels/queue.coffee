Connector = require "../connector"

class Queue extends Connector
  
  constructor: (configuration) ->
    super configuration
    @channel = "queue.#{@channel}"
    @transport.bus.on "transport.dequeue.*.success", (message) =>
      @bus.send "#{@channel}.dequeue.#{message.id}.success", message
    @transport.bus.on "transport.dequeue.*.error", (error) =>
      @bus.send "#{@channel}.dequeue.error", error
    
  enqueue: (message) ->
    message = @enrich message
    @transport.enqueue message
    @transport.bus.once "transport.enqueue.#{message.id}.success", =>
      @bus.send "#{@channel}.enqueue.#{message.id}.success"
    @transport.bus.once "transport.enqueue.#{message.id}.error", (error) =>
      @bus.send "#{@channel}.enqueue.#{message.id}.error"
    
  dequeue: ->
    @transport.dequeue @channel
    
module.exports = Queue