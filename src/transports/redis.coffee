redis = require "redis"
{Pool} = require "generic-pool"
{streamline} = require "fairmont"
Bus = require "node-bus"

# Error monad function
mError = (thing) ->
  if thing instanceof Error then thing else new Error thing.toString()
    
class Transport
  
  constructor: (configuration) ->
    {@timeout,@bus,debug} = configuration 
    @bus ?= new Bus
    @clients = Pool 
      name: "redis-transport", max: 10
      create: (callback) => 
        {port, host, options} = configuration
        client = redis.createClient port, host, options
        client.on "error", (error) -> callback error
        client.on "connect", -> callback null, client
      destroy: (client) => client.quit()
      log: (string,level) => @bus.send "transport.pool.#{level}", string
  
  send: (message) ->
    @_send message, "send"
    
  receive: (channel) ->
    @_receive channel, "receive"
    
  enqueue: (message) ->
    @_send message, "enqueue"
    
  dequeue: (message) ->
    @_receive message, "dequeue"
    
  _send: (message,verb) ->
    {channel,id} = message
    handler = streamline (error) => 
      @bus.send "#{channel}.#{id}.#{verb}.error", mError error
    @clients.acquire handler (client) =>
      client.lpush "#{channel}", JSON.stringify(message), handler (result) =>
        @clients.release client
        @bus.send "#{channel}.#{id}.#{verb}"
      
  _receive: (channel,verb) ->
    handler = streamline (error) => 
      @bus.send "#{channel}.#{verb}.error", mError error
    @clients.acquire handler (client) =>
      client.brpop "#{channel}", 0, handler (results) =>
        @clients.release client
        try
          [key,json] = results
          message = JSON.parse(json)
          {channel,id} = message
          @bus.send "#{channel}.#{id}.#{verb}", message
        catch error
          @bus.send "#{channel}.#{verb}.error", mError error

  publish: (message) ->
    {channel,id} = message
    handler = streamline (error) => 
      @bus.send "#{channel}.publish.error", mError error
    @clients.acquire handler (client) =>
      client.publish channel, JSON.stringify(message), handler =>
        @clients.release client
        @bus.send "#{channel}.#{id}.publish", message
        
    
  subscribe: (channel) ->
    _client = null
    errorHandler = (error) => 
      @bus.send "#{channel}.subscribe.error", mError error
    handler = streamline errorHandler
    @clients.acquire handler (client) =>
      _client = client
      client.subscribe channel
      client.on "message", (channel,json) =>
        try
          message = JSON.parse json
          {id} = message
          @bus.send "#{channel}.message", message
        catch error
          @bus.send "#{channel}.subscribe.error", message
          
    # we return the unsubscribe function
    =>
      if _client?
        _client.unsubscribe()
        @bus.send "#{channel}.unsubscribe"
        @clients.release _client
        
        
  end: -> 
    @clients.drain => @clients.destroyAllNow()
  

module.exports = Transport