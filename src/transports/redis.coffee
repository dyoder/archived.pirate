redis = require "redis"
{Pool} = require "generic-pool"
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
      log: (string,level) => @bus.event "transport.pool.#{level}", string
  
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
    @_acquire (client) =>
      client.lpush "#{channel}", JSON.stringify(message), (error,result) =>
        unless error?
          @clients.release client
          @bus.event "#{channel}.#{id}.#{verb}"
        else
          @bus.event "#{channel}.#{id}.#{verb}.error", mError error
        
  _receive: (channel,verb) ->
    @_acquire (client) =>
      client.brpop "#{channel}", 0, (error,results) =>
        unless error?
          @clients.release client
          try
            [key,json] = results
            message = JSON.parse(json)
            {channel,id} = message
            @bus.event "#{channel}.#{id}.#{verb}", message
          catch error
            @bus.event "#{channel}.#{verb}.error", mError error
        else
          @bus.event "#{channel}.#{verb}.error", mError error

  publish: (message) ->
    {channel,id} = message
    @_acquire (client) =>
      client.publish channel, JSON.stringify(message), (error) =>
        unless error?
          @clients.release client
          @bus.event "#{channel}.#{id}.publish", message
        else
          @bus.event "#{channel}.publish.error", mError error
        
    
  subscribe: (channel) ->
    _client = null
    @_acquire (client) =>
      _client = client
      client.subscribe channel
      client.on "message", (channel,json) =>
        try
          message = JSON.parse json
          {id} = message
          @bus.event "#{channel}.#{id}.message", message
        catch error
          @bus.event "#{channel}.subscribe.error", message
          
    # we return the unsubscribe function
    =>
      if _client?
        _client.unsubscribe => @clients.release _client
        @bus.event "#{channel}.unsubscribe"
        
        
  _acquire: (handler) ->
    # the try-catch is required because the pool library can throw exceptions as
    # well as return them via the callback :/    
    try 
      @clients.acquire (error,client) =>
        unless error?
          handler client
        else
          @bus.event "transport.client.error", mError error
    catch error
      @bus.event "transport.client.error", mError error
       
  _release: (client) -> @clients.release client
    
  end: -> 
    @clients.drain => @clients.destroyAllNow()
  

module.exports = Transport