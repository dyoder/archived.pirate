Messenger = require "../../channels/messenger"
Connector = require "../../connector"

class Request extends Connector
  
  constructor: (configuration) ->

    super configuration
    
    {@channel,@timeout} = configuration
    @timeout ?= 60 * 1000 # 60 seconds in milliseconds

    @_from = new Messenger
      channel: "reply.#{@channel}"
      transport: @transport
      
    @_to = new Messenger
      channel: "request.#{@channel}"
      transport: @transport
      
    @_counter = 0
    @_callbacks = {}
    @_timeouts = {}

  request: (message,callback) ->
    message = @enrich message
    if callback
      message.id = @_counter++
      @_registerCallback message.id, callback
      @_listen()
      @_registerTimeout message.id
      
    @_to.send message

  _registerCallback: (id,callback) ->
    @logger.info "Registering callback for message ID #{id}"
    @_callbacks[id] = callback
    
  _process: (message) ->
    @logger.info "Invoking callback for messaage ID #{message.id}"
    
    clearTimeout @_timeouts[message.id]
    @_timeouts[message.id] = null
    
    callback = @_callbacks[message.id]
    if callback
      @_callbacks[message.id] = null
      callback null, message
    else
      @logger.error "No callback found for message ID #{message.id}"
    
  end: -> 
    @_from.end()
    @_to.end()
  
  _listen: ->
    @_from.receive (error,message) =>
      # TODO: what do i do with an error here?
      # See ticket #19
      @_process message

  _registerTimeout: (id) ->
    @_timeouts[id] = (setTimeout (@_timeoutHandler id), @timeout)

  _timeoutHandler: (id) ->
    =>
      @logger.error "Timeout expired for message ID #{id}"
      callback = @_callbacks[id]
      @_callbacks[id] = null
      callback(new Error "Timeout for message #{id}")
    
module.exports = Request