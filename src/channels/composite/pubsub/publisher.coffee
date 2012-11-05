Messenger = require "../../messenger"
Subscription = require "../../subscription"
Channel = require "../../../channel"

class Publisher extends Channel
  
  constructor: (configuration) ->

    super configuration
    
    @_subscription = new Subscription
      name: @name
      transport: @transport
      replyTo: @replyTo
      
    @_results = new Messenger
      name: @replyTo
      transport: @transport
      
    @_started = false
    @_stopped = false
    @_pending = 0

  publish: (message) ->
    @_pending++
    message = @envelope message
    @_subscription.publish message
    @_run() unless @_started
    message.id
    

  _run: ->
    @_started = true
    _run = => @_results.receive()
    _run()

    # Remap receive events on our private channel to result
    # events on the publish channel and check for next event
    @_results.bus.on "#{@replyTo}.*.receive", (message) =>
      @_pending--
      @bus.event "#{@name}.#{message.id}.reply", message
      process.nextTick _run unless @_stopped
      if @_stopped and @_pending is 0
        @_subscription.end()
        @_results.end()

  end: -> 
    @_stopped = true
    
module.exports = Publisher