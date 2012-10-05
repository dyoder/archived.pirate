redis = require "redis"
{Pool} = require "generic-pool"

class Transport
  
  constructor: (@configuration) ->
    @clients = Pool 
      name: "redis-transport", max: 10, log: false
      create: (callback) => 
        {port, host, options} = @configuration
        client = redis.createClient port, host, options
        client.on "error", (error) -> callback error
        client.on "connect", -> callback null, client
      destroy: (client) -> client.quit()
  
  publish: (message) ->
    {channel} = message
    @clients.acquire (error,client) =>
      client.publish channel, JSON.stringify(message), =>
        @clients.release client
    
  subscribe: (channel,callback) ->
    @clients.acquire (error,client) =>
      client.subscribe channel
      client.on "message", (channel,json) =>
        message = JSON.parse json
        callback message
        
  send: (message) ->
    {channel} = message
    @clients.acquire (error,client) =>
      # TODO: Error handling is pending a overarching error-handling strategy
      client.lpush "queue.#{channel}", JSON.stringify(message), (error,result) =>
        @clients.release client
    
  receive: (channel,callback) ->
    @clients.acquire (error,client) =>
      client.brpop "queue.#{channel}", 0, (error,results) =>

        @clients.release client

        # process the results
        [key,json] = results if results
        message = JSON.parse(json)
        callback(error,message)
    
  end: -> 
    @clients.drain => @clients.destroyAllNow()
    
module.exports = Transport