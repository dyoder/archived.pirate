config =
  transport:
    host: "localhost"
    port: 6379
  channel:
    channel: "greetings"
    debug: false

Transport = require "../src/transports/redis"

make = (Class) ->
  config.channel.transport = new Transport config.transport
  new Class config.channel

module.exports =
  config: config
  make: make
