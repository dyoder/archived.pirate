Worker = require "../../src/patterns/worker/worker"
Transport = require "../../src/transports/redis"

transport = new Transport host: "localhost", port: 6379
worker = new Worker channel: "greetings", transport: transport
worker.accept (error,message) ->
  message.content = "Hello #{message.content}!"
worker.end()