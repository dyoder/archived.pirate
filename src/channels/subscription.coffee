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
    @transport.subscribe @channel, (error, message) ->
      callback(error, message)
      
  end: -> @transport.end()
    
module.exports = Subscription