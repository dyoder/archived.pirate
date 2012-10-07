testify = require("./testify")

testify "Simple request/reply", (test) ->


  Reply = require "../src/patterns/request-reply/reply"
  Request = require "../src/patterns/request-reply/request"
  Transport = require "../src/transports/redis"

  request = (message,callback) ->
    
    transport = new Transport host: "localhost", port: 6379
    requests = new Request channel: "greetings", transport: transport
    
    requests.request message, callback
    
    requests.end()    
    
    
  reply = (callback) ->

    transport = new Transport host: "localhost", port: 6379
    replies = new Reply channel: "greetings", transport: transport

    replies.reply callback
    
    replies.end()
    

  request "Dan", (error,message) ->
    test.assert.equal "Hello Dan!", message?.content
    test.done()
    
  reply (error,message) -> 
    test.assert.ifError error
    "Hello #{message.content}!"





