testify = require("./testify")

testify "Dispatcher and worker", (test) ->

  Dispatcher = require "../src/patterns/worker/dispatcher"
  Worker = require "../src/patterns/worker/worker"
  Transport = require "../src/transports/redis"
  
  dispatch = (message,callback) ->
    
    transport = new Transport host: "localhost", port: 6379
    dispatcher = new Dispatcher name: "dispatcher", channel: "greetings", transport: transport

    dispatcher.request "Dan", callback
    
    dispatcher.end()



  work = (callback) ->

    transport = new Transport host: "localhost", port: 6379
    worker = new Worker channel: "greetings", transport: transport

    worker.accept callback

    worker.end()
    
  dispatch "Dan", (error,message) ->
    test.assert.equal "Hello Dan!", message?.content
    test.done()
  
  work (error,message) -> 
    test.assert.ifError error
    "Hello #{message.content}!"