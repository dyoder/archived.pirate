Messenger = require "../../channels/messenger"
Queue = require "../../channels/queue"
Connector = require "../../connector"

class Worker extends Connector
  
  constructor: (configuration) ->
  
    super configuration
    {@channel} = configuration
  
    @_from = new Queue
      channel: "request.#{@channel}"
      transport: @transport

    @_messengers = {}
    @_pending = 0
    @_finish = false
 
  accept: (callback) ->
    @_pending++
    @_from.dequeue (error,message) =>
      response = @enrich callback error, message
      response.id = message.id
      @_getMessenger(message.replyTo).send response
      @_end() if --@_pending is 0 and @_finish is true

  end: ->
    @_finish = true
    @_end() if @_pending is 0

  _end: ->
    @_from.end()
    for channel,messenger of @_messengers
      messenger.end()
    @_messengers = []

     
  _getMessenger: (channel) ->
    @_messengers[channel] ?= new Messenger
      channel: channel
      transport: @transport
      
module.exports = Worker