testify = require "./testify"
{make} = require "./helpers"
Queue = require "../src/channels/queue"
  

testify "Queue and dequeue a request", (test) ->
  
  enqueue = (message) ->

    queue = make Queue
    queue.enqueue message
    queue.end()
  
  dequeue = (callback) ->

    queue = make Queue
    queue.dequeue callback
    queue.end()
  
  enqueue "Hello!"
  dequeue (error,message) ->
    test.assert.equal "Hello!", message?.content
    test.done()
  