Messenger = require "../../channels/messenger"
Queue = require "../../channels/queue"
Connector = require "../../connector"

class Dispatcher extends Connector
  
  constructor: (configuration) ->

    super configuration
    {@name,@channel,@timeout} = configuration
    @timeout ?= 60 * 1000 # 60 seconds in milliseconds

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

  request: (message,callback) ->
    message = @enrich message
    if callback
      message.id = @_counter++
      @_registerCallback message.id, callback
      @_listen()
      @_registerTimeout message.id
      
    @_to.enqueue message
    
  end: -> 
    @_from.end()
    @_to.end()

  _listen: ->
    @_from.receive (error,reply) =>
      # TODO: what do i do with an error here?
      # See issues #19, #20.
      @_process reply

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

  _registerCallback: (id,callback) ->
    @logger.info "Registering callback for message ID #{id}"
    @_callbacks[id] = callback
    
  _registerTimeout: (id) ->
    @_timeouts[id] = (setTimeout (@_timeoutHandler id), @timeout)
    
  _timeoutHandler: (id) ->
    =>
      @logger.error "Timeout expired for message ID #{id}"
      callback = @_callbacks[id]
      @_callbacks[id] = null
      callback(new Error "Timeout for message #{id}")
    
module.exports = Dispatcher