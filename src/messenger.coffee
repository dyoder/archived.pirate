Queue = require "./channels/queue"
Subscription = require "./channels/subscription"

class Messenger
  
  constructor: (@name,@transport) ->
    
  queue: (name) ->
    new Queue
      name: name
      transport: @transport
      replyTo: @name
      
  subscription: (channel) ->
    new Subscription
      channel: channel
      transport: @transport
      replyTo: @name
  

module.exports = Messenger