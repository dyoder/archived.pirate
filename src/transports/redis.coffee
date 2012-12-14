redis = require "redis"
{Pool} = require "generic-pool"
Bus = require "node-bus"
{type,toError} = require "fairmont"

class Transport
  
  constructor: (configuration) ->
    {@timeout,@bus,debug} = configuration 
    @bus ?= new Bus
    ch = @bus.channel "pool"
    @clients = Pool 
      name: "redis-transport", max: 10
      create: (callback) => 
        {port, host, options} = configuration
        client = redis.createClient port, host, options
        client.on "error", (error) -> callback error
        client.on "connect", -> callback null, client
      destroy: (client) => client.quit()
      log: (string,level) => ch.send level, string
  
  send: (message) -> @_send message, "send"
    
  receive: (channel) -> @_receive channel, "receive"
    
  enqueue: (message) -> @_send message, "enqueue"
    
  dequeue: (channel) -> @_receive channel, "dequeue"
    
  _send: (message,verb) ->
    @bus.channel verb, (ch) =>
      {channel,id} = message
      @_acquire (client) =>
        ch.once "*", => @clients.release client
        client.lpush channel, JSON.stringify(message), ch.callback
        
  _receive: (channel,verb) ->
    @bus.channel verb, (ch) =>
      @_acquire (client) =>
        ch.once "*", => @clients.release client
        channel = if (type channel) is "array" then channel else [ channel ]
        client.brpop channel..., 0, ch.callback
      ch.on "success", (results) =>
        ch.safely =>
          [key,json] = results
          message = JSON.parse(json)
          ch.send "message", message

  publish: (message) ->
    @bus.channel "publish", (ch) =>
      {channel,id} = message
      @_acquire (client) =>
        ch.once "*", => @clients.release client
        client.publish channel, JSON.stringify(message), ch.callback
          
  subscribe: (channel) ->
    @bus.channel "subscribe", (ch) =>
      @_acquire (client) =>
        client.subscribe channel
        client.on "message", (channel,json) =>
          ch.safely =>
            message = JSON.parse json
            ch.send "message", message
        ch.once "unsubscribe", =>
          if client?
            client.unsubscribe => @clients.release client
        
  _acquire: (handler) ->
    @bus.channel "client", (ch) =>
      ch.safely => @clients.acquire ch.callback
      ch.on "success", handler
       
  _release: (client) -> @clients.release client
    
  end: -> @clients.drain => @clients.destroyAllNow()
  
module.exports = Transport