Queue = require "../../src/channels/queue"
Transport = require "../../src/transports/redis"

transport = new Transport host: "localhost", port: 6379
queue = new Queue channel: "greetings", transport: transport
queue.dequeue (error,message) ->
  console.log (if error then error else message.content)
queue.end()