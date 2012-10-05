Messenger = require "../../src/messenger"
Transport = require "../../src/transports/redis"

messenger = new Messenger "worker", new Transport host: "localhost", port: 6379
queue = messenger.queue "greetings"
queue.dequeue (error,message) ->
  console.log (if error then error else message.content)
queue.end()