testify = require "./testify"
{make} = require "./helpers"
Subscription = require "../src/channels/subscription"

testify "Publish and subscribe", (test) ->

  publisher = make Subscription
  publisher.on "*.error", (error) -> test.fail error
  
  # Give it a second to make sure the subscribe is set up
  setTimeout (-> publisher.publish "Hello!"; publisher.end() ), 100
  

  subscriber = make Subscription
  subscriber.subscribe()
  id = setTimeout (-> test.fail "Never got publish" ; process.exit() ), 1000
  subscriber.on "#{subscriber.name}.message", (message) ->
    clearTimeout id
    subscriber.unsubscribe()
    test.assert.equal "Hello!", message?.content    
    test.done()
  subscriber.end()
