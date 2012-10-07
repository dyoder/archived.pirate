class Subscription
  
  constructor: (configuration) ->
    {@channel,@transport,@replyTo,@logger} = configuration
    @logger ?= @transport.logger
    @channel = "subscription.#{@channel}"
    
  publish: (content,callback) ->
    @transport.publish
      channel: @channel
      replyTo: @replyTo
      content: content
      callback

  subscribe: (callback) ->
    @_unsubscribe = @transport.subscribe @channel, (error, message) ->
      callback(error, message)
      
  unsubscribe: -> 
    if @_unsubscribe
      @_unsubscribe()
      @_unsubscribe = null
      
  end: -> @transport.end()
    
module.exports = Subscription