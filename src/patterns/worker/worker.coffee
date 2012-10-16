Messenger = require "../../channels/messenger"
Queue = require "../../channels/queue"
Connector = require "../../connector"

class Worker extends Connector
  
  constructor: (configuration) ->
  
    super configuration
  
    @_from = new Queue
      channel: "request.#{@channel}"
      transport: @transport

    @_messengers = {}
    @_pending = 0
    @_finish = false
 
  accept: (callback) ->
    @_pending++
    @_from.dequeue (error,message) =>
      callback error, message, (error,response) =>
        unless error
          @logger.info "Processed message #{message.id}"
          response = @enrich response
          response.id = message.id
          @_getMessenger(message.replyTo).send response, (error,result) ->
            if error
              @logger.error "Unable to send response for message #{message.id}"
          @_end() if --@_pending is 0 and @_finish is true
        else
          @logger.error "Unable to process message #{message.id} (#{error.name}: #{error.message})"

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