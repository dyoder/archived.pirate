testify = require "./testify"
{make} = require "./helpers"
Dispatcher = require "../src/channels/composite/worker/dispatcher"
Worker = require "../src/channels/composite/worker/worker"

testify "Dispatcher and worker", (test) ->
  
  errorHandler = (error) -> test.fail error
    
  dispatcher = make Dispatcher
  dispatcher.bus.on "*.error", errorHandler
  dispatcher.request "Dan"
  dispatcher.bus.on "greetings.*.result", (result) ->
    test.assert.equal "Hello Dan!", result?.content
    test.done()
  dispatcher.end()

  worker = make Worker
  worker.bus.on "*.error", errorHandler
  worker.accept()
  worker.bus.on "greetings.*.task", (task,result) ->
    worker.bus.event "greetings.#{task.id}.result", "Hello #{task.content}!"
  worker.end()
  