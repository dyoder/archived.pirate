testify = require "./testify"
{config,make} = require "./helpers"
Subscription = require "../src/channels/subscription"

testify "Publish and subscribe", (test) ->

  publish = (message) ->
    
    subscription = make Subscription
    subscription.publish message
    subscription.end()



  subscribe = (callback) ->
    
    subscription = make Subscription
    subscription.subscribe (error,message) ->
      subscription.unsubscribe()
      callback error, message
    subscription.end()


  id = setTimeout (-> test.fail "Never got publish" ; process.exit() ), 1000
  
  subscribe (error,message) ->
    clearTimeout(id)
    test.assert.equal "Hello!", message?.content    
    test.done()

  # Give it a second to make sure the subscribe is set up
  setTimeout (-> publish "Hello!"), 100
  
