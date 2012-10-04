redis = require "redis"
{Pool} = require "generic-pool"

class Transport
  
  constructor: (@configuration) ->
    @clients = Pool 
      name: "redis-transport", max: 10, log: true
      create: (callback) => 
        {port, host, options} = @configuration
        client = redis.createClient port, host, options
        client.on "error", (error) -> callback error
        client.on "connect", -> callback null, client
      destroy: (client) -> client.quit()
      
  send: (message) ->
    {channel} = message
    # get a client from the pool ...
    @clients.acquire (error,client) =>
      # TODO: Error handling is pending a overarching error-handling strategy
      client.lpush "queue.#{channel}", JSON.stringify(message), (error,result) =>
        # return the client to the pool ...
        @clients.release client
    
  receive: (channel,callback) ->
    # get a client from the pool ...
    @clients.acquire (error,client) =>
      client.brpop "queue.#{channel}", 0, (error,results) =>

        # return the client to the pool ...
        @clients.release client

        # process the results
        [key,json] = results if results
        message = JSON.parse(json)
        callback(error,message)
    
  end: -> 
    @clients.drain => @clients.destroyAllNow()
    
module.exports = Transport