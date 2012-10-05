Messenger = require "../../src/messenger"
Transport = require "../../src/transports/redis"

messenger = new Messenger "subscriber", new Transport host: "localhost", port: 6379
subscription = messenger.subscription "greetings"
subscription.subscribe (error,message) ->
  console.log (if error then error else message.content)
  subscription.unsubscribe()
subscription.end()