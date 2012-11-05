Messenger = require "../../messenger"
Subscription = require "../../subscription"
Channel = require "../../../channel"

class Subscriber extends Channel
  
  constructor: (configuration) ->
  
    super configuration
  
    @_subscription = new Subscription
      name: @name
      transport: @transport
      
    @_messengers = {}
    @_started = false
    @_stopped = false
    
  listen: -> @_run() unless @_started   
    
  _run: ->

    @_started = true

    @_subscription.subscribe()

    @_subscription.bus.on "#{@name}.*.message", (message) =>

      # Grab the channel and id from the message ...
      {replyTo,id} = message
      
      # listen for the result event ...
      # TODO: this will create a memory leak if there's no response
      @bus.once "#{@name}.#{id}.reply", (result) =>    
        (@_messenger replyTo).send content: result, id: id
        # TODO: what if there several outstanding listeners like this?
        @_subscription.end() if @_stopped

  _messenger: (name) ->
    @_messengers[name] ?= new Messenger
      name: name
      transport: @transport
      
  end: -> 
    @_stopped = true
    
      
module.exports = Subscriber