class Subscription
  
  constructor: (configuration) ->
    {@channel,@transport,@replyTo} = configuration
    @channel = "subscription.#{@channel}"
    
  publish: (content) ->
    @transport.publish
      channel: @channel
      replyTo: @replyTo
      content: content

  subscribe: (callback) ->
    # TODO: this is probably a bit too clever for our own good ...
    # We can just set _unsubscribe here and then conditionally call it from the
    # "real" unsubscribe method instead of replacing it. That way we can also
    # reset it to null when we're done.
    @unsubscribe = @transport.subscribe @channel, (error, message) ->
      callback(error, message)
      
  unsubscribe: -> 
      
  end: -> @transport.end()
    
module.exports = Subscription