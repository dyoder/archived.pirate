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
    action = "Send message: #{message.content[0..15]}"
    @logger.info "#{action} ..."
    {channel} = message
    @clients.acquire (error,client) =>
      if error
        @logger.error "#{action} - #{error.name}: #{error.message}"
      else
        client.lpush "queue.#{channel}", JSON.stringify(message), (error,result) =>
          @clients.release client
          if error
            @logger.error "#{action} - #{error.name}: #{error.message}"
          else
            @logger.info "#{action} successful"

          callback error, result if callback

  receive: (channel,callback) ->
    action = "Receive message on channel: #{channel}"
    @logger.info "#{action} ..."
    @clients.acquire (error,client) =>
      if error
        @logger.error "#{action} - #{error.name}: #{error.message}"
      else
        client.brpop "queue.#{channel}", 0, (error,results) =>
          @clients.release client
          if error
            @logger.error "#{action} - #{error.name}: #{error.message}"
          else
            @logger.info "#{action} successful"

          try
            [key,json] = results
            callback null, JSON.parse(json)
          catch error
            error = new Error("Transport receieve method returned unexpected
              result ('#{error.name}: #{error.message})'")
            @logger.error "#{action} - #{error.name}: #{error.message}"
            callback error

  enqueue: (message) -> @send message
  
  dequeue: (channel,callback) -> @receive channel, callback

  publish: (message,callback) ->
    action = "Publish message: #{message.content[0..15]}"
    {channel} = message
    @logger.info "#{action} ..."
    @clients.acquire (error,client) =>
      if error
        @logger.error "#{action} - #{error.name}: #{error.message}"
      else
        client.publish channel, JSON.stringify(message), (error) =>
          @clients.release client
          if error
            @logger.error "#{action} - #{error.name}: #{error.message}"
          else
            @logger.info "#{action} successful"
        
    
  subscribe: (channel,callback) ->
    action = "Subscribe to channel: #{channel}"
    _client = null
    @logger.info "#{action} ..."
    @clients.acquire (error,client) =>
      _client = client
      if error
        @logger.error "#{action} - #{error.name}: #{error.message}"
      else
        client.subscribe channel
        client.on "message", (channel,json) =>
          try
            callback null, JSON.parse(json)
          catch error
            error = new Error("""
              Transport subscribe method returned unexpected result ('#{error.name}: #{error.message}')
            """)
            @logger.error "#{action} - #{error.name}: #{error.message}"
            callback error
          
    # we return the unsubscribe function
    if _client?
      =>
        _client.unsubscribe()
        @clients.release _client
        
  end: -> 
    @clients.drain => @clients.destroyAllNow()
  
  log_error: (error) ->
    @logger.error "#{error.name}: #{error.message}"
    
module.exports = Transport