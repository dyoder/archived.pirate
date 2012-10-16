Messenger = require "../../channels/messenger"
Queue = require "../../channels/queue"
Connector = require "../../connector"

class Dispatcher extends Connector
  
  constructor: (configuration) ->

    super configuration
    {@timeout,@retries} = configuration
    @timeout ?= 60 * 1000 # 60 seconds in milliseconds
    @retries ?= 0

    @_from = new Messenger
      channel: "private.#{@name}"
      transport: @transport
      
    @_to = new Queue
      channel: "request.#{@channel}"
      transport: @transport
      replyTo: "private.#{@name}"
      
    @_counter = 0
    @_callbacks = {}
    @_timeouts = {}
    @_retries = {}

  request: (message,callback) ->
    message = @enrich message
    message.id = @_counter++
    callback ?= (error,response) -> 
    @_registerCallback message.id, callback
    @_listen()
    @_registerTimeout message
    @_to.enqueue message
    
  end: -> 
    @_from.end()
    @_to.end()

  _listen: ->
    @_from.receive (error,message) =>
      # TODO: what do i do with an error here?
      # See issues #19, #20.
      unless error
        @_process message
      else
        @logger.error "#{error.name}: #{error.message}"

  _process: (message) ->
    
    @logger.info "Invoking callback for messaage ID #{message.id}"

    clearTimeout @_timeouts[message.id]
    @_timeouts[message.id] = null
    
    @_fireCallback message.id, null, message

  _registerCallback: (id,callback) ->
    @logger.info "Registering callback for message ID #{id}"
    @_retries[id] = 0
    @_callbacks[id] = callback
    
  _fireCallback: (id,error,response) ->
    callback = @_callbacks[id]
    if callback
      @_callbacks[id] = null
      @_retries[id] = null
      callback error, response
    else
      @logger.warn "Unknown message ID: #{id}"
    
    
  _registerTimeout: (message) ->
    @_timeouts[message.id] = (setTimeout (@_timeoutHandler message), @timeout)
    
  _timeoutHandler: (message) ->
    =>
      @logger.error "Timeout expired for message ID #{message.id}"
      if @_retries[message.id] < @retries 
        @_retries[message.id]++
        @_listen()
        @_registerTimeout message
        @_to.enqueue message
      else
        @_fireCallback message.id, new Error "Message timed out: #{message.id}"
    
module.exports = Dispatcher