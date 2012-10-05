Subscription = require "../../src/channels/subscription"
Transport = require "../../src/transports/redis"

transport = new Transport host: "localhost", port: 6379
subscription = new Subscription channel: "greetings", transport: transport
subscription.subscribe (error,message) ->
  console.log (if error then error else message.content)
  subscription.unsubscribe()
subscription.end()