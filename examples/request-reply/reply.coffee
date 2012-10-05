RequestReply = require "../../src/patterns/request-reply"
Transport = require "../../src/transports/redis"

transport = new Transport host: "localhost", port: 6379
channel = new RequestReply channel: "greetings", transport: transport
channel.reply (error,message) ->
  message.content.replace("!",", Dan!")
channel.end()