{w} = require "fairmont"

testify = require "./testify"
{make} = require "./helpers"
PriorityQueue = require "../src/channels/priority-queue"
  

testify "Queue and dequeue a request", (test) ->
  
  # Fail the test on an error
  errorHandler = (error) ->
    # console.log error
    test.fail()
  
  # Okay, first let's send a message
  from = make PriorityQueue
  from.bus.on "#{from.name}.*.error", errorHandler
  from.enqueue content: "Five", priority: 5
  from.enqueue content: "Three", priority: 3
  from.enqueue content: "One", priority: 1
  from.enqueue content: "Four", priority: 4
  from.enqueue content: "Two", priority: 2
  # We call end here because we want to make sure that the test still succeeds
  # and doesn't wipe out pending messages  
  from.end()
  
  # Next, let's dequeue one ...
  to = make PriorityQueue
  results = []
  to.bus.on "#{to.name}.*.error", errorHandler
  to.bus.on "#{to.name}.*.dequeue", (message) ->
    results.push message?.content
    if results.length is 5
      words = (w "One Two Three Four Five")
      for result,i in results
        test.assert.equal result, words[i]
      test.done()
      to.end()
    else
      to.dequeue()
  to.dequeue()
  
