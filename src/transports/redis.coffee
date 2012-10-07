redis = require "redis"
{Pool} = require "generic-pool"

_default_logger = (level) ->
  Logger = require "../logger"
  new Logger level: level
      
class Transport
  
  constructor: (configuration) ->
    {@logger,debug} = configuration 
    @logger ?= _default_logger(if debug? then "info" else "error")
    @clients = Pool 
      name: "redis-transport", max: 10
      create: (callback) => 
        {port, host, options} = configuration
        client = redis.createClient port, host, options
        client.on "error", (error) -> callback error
        client.on "connect", -> callback null, client
      destroy: (client) => client.quit()
      log: (string,level) => @logger[level](string)
  
  send: (message,callback) ->
    @logger.info "Sending message: #{message.content[0..15]} ..."
    {channel} = message
    callback = (=> @log_error) unless callback
    @clients.acquire (error,client) =>
      if error then return callback(error)
      client.lpush "queue.#{channel}", JSON.stringify(message), (error,result) =>
        @clients.release client
        callback error, result

  receive: (channel,callback) ->
    @clients.acquire (error,client) =>
      if error then return callback(error)
      client.brpop "queue.#{channel}", 0, (error,results) =>
        @clients.release client
        # process the results
        if error then return callback error
        try
          [key,json] = results
          callback null, JSON.parse(json)
        catch error
          callback new Error("Transport receieve method returned unexpected
            result ('#{error.name}: #{error.message})'")

  enqueue: (message) -> @send message
  
  dequeue: (channel,callback) -> @receive channel, callback

  publish: (message,callback) ->
    {channel} = message
    callback = (=> @log_error) unless callback
    @clients.acquire (error,client) =>
      if error then return callback(error)
      client.publish channel, JSON.stringify(message),(error) =>
        @clients.release client
        if error then return callback error
        
    
  subscribe: (channel,callback) ->
    _client = null
    @clients.acquire (error,client) =>
      if error then return callback(error)
      _client = client
      client.subscribe channel
      client.on "message", (channel,json) =>
        message = JSON.parse json
        callback null, message
    # we return the unsubscribe function
    =>
      _client.unsubscribe()
      @clients.release _client
        
  end: -> 
    @clients.drain => @clients.destroyAllNow()
  
  log_error: (error) ->
    @logger.error "#{error.name}: #{error.message}"
    
module.exports = Transport