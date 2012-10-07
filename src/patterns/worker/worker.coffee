Messenger = require "../../channels/messenger"
Queue = require "../../channels/queue"

class Worker
  
  constructor: (configuration) ->
  
    {@channel,@transport,@logger} = configuration
    @logger ?= @transport.logger
  
    @_from = new Queue
      channel: "request.#{@channel}"
      transport: @transport

    @_messengers = {}
    @_pending = 0
    @_finish = false
 
  accept: (callback) ->
    @_pending++
    @_from.dequeue (error,message) =>
      @_getMessenger(message.replyTo).send callback error,message
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