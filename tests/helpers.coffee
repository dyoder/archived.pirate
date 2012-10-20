defaults =
  transport:
    host: "localhost"
    port: 6379
  channel:
    name: "greetings"
    debug: true

Transport = require "../src/transports/redis"

extend = (object, mixins...) ->
  for mixin in mixins
    for key, value of mixin
      object[key] = value
  object
    
make = (Class,configuration={}) ->
  configuration = extend {}, defaults.channel, configuration
  configuration.transport = new Transport defaults.transport
  new Class configuration

module.exports =
  make: make
