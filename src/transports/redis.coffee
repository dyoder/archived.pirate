redis = require "redis"
{Pool} = require "generic-pool"

_default_logger = ->
  Logger = require "../logger"
  new Logger level: "error"
      
class Transport
  
  constructor: (configuration) ->
    {@logger,@timeout,debug} = configuration 
    @logger ?= _default_logger()
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
    {channel} = message
    action = "Send message on channel: #{channel}"
    @logger.info "#{action}"
    @clients.acquire (error,client) =>
      if error
        @logger.error "#{action} - #{error.name}: #{error.message}"
      else
        client.lpush "queue.#{channel}", JSON.stringify(message), (error,result) =>
          @clients.release client
          if error
            @logger.error "#{action} - #{error.name}: #{error.message}"
          else
            @logger.info "#{action} << SUCCESS >>"

          callback error, result if callback

  receive: (channel,callback) ->
    action = "Receive message on channel: #{channel}"
    @logger.info "#{action}"
    @clients.acquire (error,client) =>
      if error
        @logger.error "#{action} - #{error.name}: #{error.message}"
      else
        client.brpop "queue.#{channel}", 0, (error,results) =>
          @clients.release client
          if error
            @logger.error "#{action} - #{error.name}: #{error.message}"
          else
            @logger.info "#{action} << SUCCESS >>"

          try
            [key,json] = results
            message = JSON.parse(json)
          catch error
            error = @unexpected "receive", error
            @logger.error "#{action} - #{error.name}: #{error.message}"
            callback error

          callback null, message

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
            @logger.info "#{action} successful"
          catch error
            error = @_unexpected "subscribe", error
            @logger.error "#{action} - #{error.name}: #{error.message}"
            callback error
          
    # we return the unsubscribe function
    =>
      if _client?
        @logger.info "Unsubscribing ..."
        _client.unsubscribe()
        @clients.release _client
        
        
  unexpected: (method,error) ->
    new Error("""
      Transport #{method} method returned unexpected result ('#{error.name}: #{error.message}')
    """)
    
  end: -> 
    @clients.drain => @clients.destroyAllNow()
  

module.exports = Transport