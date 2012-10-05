RequestReply = require "../../src/patterns/request-reply"
Transport = require "../../src/transports/redis"

transport = new Transport host: "localhost", port: 6379
channel = new RequestReply channel: "greetings", transport: transport
channel.request "Hello!", (error,message) ->
  console.log (if error then error else message.content)
channel.end()