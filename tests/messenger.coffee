testify = require "./testify"
{make} = require "./helpers"
Messenger = require "../src/channels/messenger"
  

testify "Send and receive messages", (test) ->
  
  # Fail the test on an error
  errorHandler = (error) ->
    # console.log error
    test.fail()
  
  # Okay, first let's send a message
  from = make Messenger
  from.bus.on "*.error", errorHandler
  from.send "Hello!"  
  # We call end here because we want to make sure that the test still succeeds
  # and doesn't wipe out pending messages  
  from.end()
  
  # Next, let's dequeue one ...
  to = make Messenger
  to.bus.on "*.error", errorHandler
  ch = to.receive()
  ch.on "message", (message) ->
    test.assert.equal "Hello!", message?.content
    test.done()
  # Same strategy: we should process the message before exiting, even though
  # we've called end()  
  to.end()
  
