Messenger = require "../channels/messenger"

class RequestReply
  
  constructor: (configuration) ->

    {@channel,@transport} = configuration

    @from = new Messenger
      channel: "reply.#{@channel}"
      transport: @transport
      
    @to = new Messenger
      channel: "request.#{@channel}"
      transport: @transport
      
    @_counter = 0
    @_finish = false
    @_callbacks = {}

  request: (message,callback) ->
    if callback
      message.id = @_counter++
      @addCallback message.id, callback
      @_listenForReplies()
    @to.send message

  reply: (callback) ->
    @to.receive (error,message) =>
      @from.send callback error, message
      @_end() if @_finish

    
  addCallback: (id,callback) ->
    @_callbacks[id] = callback
    
  runCallback: (message) ->
    callback = @_callbacks[message.id]
    @_callbacks[message.id] = null
    callback(null,message)
    
  end: -> 
    # Don't shut down if we're still waiting for a request ...    
    if @to.isListening 
      @_finish = true
    else
      @_end()
      
  _end: ->
    @from.end()
    @to.end()
  
  _listenForReplies: ->
    @from.receive (error,reply) =>
      @runCallback reply
    
    
    
    
module.exports = RequestReply