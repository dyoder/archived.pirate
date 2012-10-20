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
      @bus.send "transport.#{verb}.#{id}.error", mError error
    @clients.acquire handler (client) =>
      client.lpush "queue.#{channel}", JSON.stringify(message), handler (result) =>
        @clients.release client
        @bus.send "transport.#{verb}.#{id}.success"
      
  _receive: (channel,verb) ->
    handler = streamline (error) => 
      @bus.send "transport.#{verb}.error", mError error
    @clients.acquire handler (client) =>
      client.brpop "queue.#{channel}", 0, handler (results) =>
        @clients.release client
        try
          [key,json] = results
          message = JSON.parse(json)
          {channel,id} = message
          @bus.send "transport.#{verb}.#{id}.success", message
        catch error
          @bus.send "transport.#{verb}.error", mError error

  # publish: (message,callback) ->
  #   action = "Publish message: #{message.content[0..15]}"
  #   {channel} = message
  #   @logger.info "#{action} ..."
  #   @clients.acquire (error,client) =>
  #     if error
  #       @logger.error "#{action} - #{error.name}: #{error.message}"
  #     else
  #       client.publish channel, JSON.stringify(message), (error) =>
  #         @clients.release client
  #         if error
  #           @logger.error "#{action} - #{error.name}: #{error.message}"
  #         else
  #           @logger.info "#{action} successful"
  #       
  #   
  # subscribe: (channel,callback) ->
  #   action = "Subscribe to channel: #{channel}"
  #   _client = null
  #   @logger.info "#{action} ..."
  #   @clients.acquire (error,client) =>
  #     _client = client
  #     if error
  #       @logger.error "#{action} - #{error}"
  #     else
  #       client.subscribe channel
  #       client.on "message", (channel,json) =>
  #         try
  #           callback null, JSON.parse(json)
  #           @logger.info "#{action} successful"
  #         catch error
  #           error = new Error "#{action} - #{error.name}: #{error.message}"
  #           @logger.error 
  #           callback error
  #         
  #   # we return the unsubscribe function
  #   =>
  #     if _client?
  #       @logger.info "Unsubscribing ..."
  #       _client.unsubscribe()
  #       @clients.release _client
  #       
        
  end: -> 
    @clients.drain => @clients.destroyAllNow()
  

module.exports = Transport