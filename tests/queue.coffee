testify = require("./testify")

testify "Queue and dequeue a request", (test) ->
  
  Queue = require "../src/channels/queue"
  Transport = require "../src/transports/redis"

  enqueue = (message) ->

    transport = new Transport host: "localhost", port: 6379
    queue = new Queue channel: "greetings", transport: transport

    queue.enqueue message

    queue.end()
  
  dequeue = (callback) ->

    transport = new Transport host: "localhost", port: 6379
    queue = new Queue channel: "greetings", transport: transport
  
    queue.dequeue callback
  
    queue.end()
  
  enqueue "Hello!"
  dequeue (error,message) ->
    test.assert.equal "Hello!", message?.content
    test.done()
  