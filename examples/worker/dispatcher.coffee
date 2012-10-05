Dispatcher = require "../../src/patterns/worker/dispatcher"
Transport = require "../../src/transports/redis"

transport = new Transport host: "localhost", port: 6379
dispatcher = new Dispatcher name: "dispatcher", channel: "greetings", transport: transport
dispatcher.request "Dan", (error,message) ->
  console.log (if error then error else message.content)
dispatcher.end()