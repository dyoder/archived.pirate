Reply = require "../../src/patterns/request-reply/reply"
Transport = require "../../src/transports/redis"

transport = new Transport host: "localhost", port: 6379
replies = new Reply channel: "greetings", transport: transport
replies.reply (error,message) ->
  "Hello #{message.content}!"
replies.end()