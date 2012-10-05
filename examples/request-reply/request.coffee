Request = require "../../src/patterns/request-reply/request"
Transport = require "../../src/transports/redis"

transport = new Transport host: "localhost", port: 6379
requests = new Request channel: "greetings", transport: transport
requests.request "Dan", (error,message) ->
  console.log (if error then error else message.content)
requests.end()