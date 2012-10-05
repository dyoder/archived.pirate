Messenger = require "../../channels/messenger"

class Worker
  
  constructor: (configuration) ->
  
    {@channel,@transport} = configuration
  
    @from = new Messenger
      channel: "request.#{@channel}"
      transport: @transport
      replyTo: "private.#{@name}"

    @_messengers = {}
    @_pending = 0
    @_finish = false
 
  accept: (callback) ->
    @_pending++
    @from.receive (error,message) =>
      @_getMessenger(message.replyTo).send callback error,message
      if --@_pending is 0 and @_finish is true
        @_end()

  end: ->
    @_finish = true
    @_end() if @_pending is 0

  _end: ->
    @from.end()
    for channel,messenger of @_messengers
      messenger.end()
    @_messengers = []

     
  _getMessenger: (channel) ->
    @_messengers[channel] ?= new Messenger
      channel: channel
      transport: @transport
      
module.exports = Worker