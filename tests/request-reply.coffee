testify = require "./testify"
{make} = require "./helpers"
Reply = require "../src/patterns/request-reply/reply"
Request = require "../src/patterns/request-reply/request"

testify "Simple request/reply", (test) ->


  Transport = require "../src/transports/redis"

  request = (message,callback) ->
    
    requests = make Request
    requests.request message, callback
    requests.end()    
    
    
  reply = (callback) ->

    replies = make Reply
    replies.reply callback
    replies.end()
    

  request "Dan", (error,message) ->
    test.assert.equal "Hello Dan!", message?.content
    test.done()
    
  reply (error,message) -> 
    test.assert.ifError error
    "Hello #{message.content}!"





