testify = require "./testify"
{make} = require "./helpers"
Dispatcher = require "../src/channels/composite/worker/dispatcher"
Worker = require "../src/channels/composite/worker/worker"

testify "Dispatcher and worker", (test) ->
  
  errorHandler = (error) ->
    test.fail error
    
  dispatcher = make Dispatcher
  dispatcher.bus.on "*.error", errorHandler
  dispatcher.request "Dan"
  dispatcher.bus.on "greetings.*.result", (result) ->
    test.assert.equal "Hello Dan!", result?.content
    test.done()
  dispatcher.end()

  # We add the timeout so that end() will return more quickly
  # just to expedite the test
  worker = make Worker, timeout: 1000
  worker.bus.on "*.error", errorHandler
  worker.accept()
  worker.bus.on "greetings.*.task", (task,result) ->
    result "Hello #{task.content}!"
  worker.end()
  