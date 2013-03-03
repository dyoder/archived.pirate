testify = require "./testify"
{make} = require "./helpers"
Queue = require "../src/channels/queue"
  

testify "Queue and dequeue a request", (test) ->
  
  # Fail the test on an error
  errorHandler = (error) ->
    # console.log error
    test.fail()
  
  # Okay, first let's send a message
  from = make Queue
  from.bus.on "*.error", errorHandler
  from.enqueue "Hello!"  
  # We call end here because we want to make sure that the test still succeeds
  # and doesn't wipe out pending messages  
  from.end()
  
  # Next, let's dequeue one ...
  to = make Queue
  to.bus.on "*.error", errorHandler
  ch = to.dequeue()
  ch.on "message", (message) ->
    test.assert.equal "Hello!", message?.content
    test.done()
  # Same strategy: we should process the message before exiting, even though
  # we've called end()  
  to.end()
  
  