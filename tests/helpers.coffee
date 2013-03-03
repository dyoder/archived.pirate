defaults =
  debug: true
  transport:
    host: "localhost"
    port: 6379
  channel:
    name: "greetings"

{w,merge} = require "fairmont"
Transport = require "../src/transports/redis"

extend = (object, mixins...) ->
  for mixin in mixins
    for key, value of mixin
      object[key] = value
  object
    
levels = w "error warn info debug verbose"
attachLogger = (node) ->
  Logger = require "ax"
  logger = new Logger level: "debug"
  node.bus.receive (event,args...) => 
    [_...,level] = event.split "."
    if level in levels
      logger[level] args.join " "
    else
      logger.info "#{event}"

make = (klass,configuration={}) ->
  configuration = merge defaults.channel, configuration
  configuration.transport = new Transport defaults.transport
  node = new klass configuration
  if defaults.debug?
    attachLogger node
  node
    

module.exports =
  make: make
          


  

