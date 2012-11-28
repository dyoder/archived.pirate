testify = require "./testify"
{make} = require "./helpers"
Publisher = require "../src/channels/composite/pubsub/publisher"
Subscriber = require "../src/channels/composite/pubsub/subscriber"

testify "Pubsub", (test) ->
  
  errorHandler = (error) -> test.fail error
    
  publisher = make Publisher
  publisher.on "*.error", errorHandler
  publisher.on "greetings.*.reply", (result) ->
    test.assert.equal "Hello Dan!", result?.content
    test.done()

  subscriber = make Subscriber
  subscriber.on "*.error", errorHandler
  subscriber.listen()

  id = setTimeout (-> test.fail "Never got publish" ; process.exit() ), 1000
  subscriber.on "greetings.*.message", (message) ->
    clearTimeout id
    {id,content} = message
    subscriber.event "greetings.#{id}.reply", "Hello #{content}!"
    subscriber.end()
      
  # Give it a second to make sure the subscribe is set up
  setTimeout (-> publisher.publish "Dan"; publisher.end()), 100
  