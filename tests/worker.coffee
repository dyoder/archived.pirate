testify = require "./testify"
{make} = require "./helpers"
Dispatcher = require "../src/patterns/worker/dispatcher"
Worker = require "../src/patterns/worker/worker"
{randomKey} = require "../src/keys"

testify "Dispatcher and worker", (test) ->

  dispatch = (message,callback) ->
    
    dispatcher = make Dispatcher, name: randomKey 16
    dispatcher.request 
      content: "Dan"
      callback
    dispatcher.end()



  work = (callback) ->

    worker = make Worker
    worker.accept callback
    worker.end()
    
  dispatch "Dan", (error,message) ->
    test.assert.equal "Hello Dan!", message?.content
    test.done()
  
  work (error,message,callback) -> 
    test.assert.ifError error
    callback null, "Hello #{message.content}!"