testify = require("./testify")

testify "Publish and subscribe", (test) ->

  Subscription = require "../src/channels/subscription"
  Transport = require "../src/transports/redis"


  publish = (message) ->
    
    transport = new Transport host: "localhost", port: 6379
    subscription = new Subscription channel: "greetings", transport: transport
    transport.logger.level = "debug"

    subscription.publish message
    
    subscription.end()



  subscribe = (callback) ->
    
    transport = new Transport host: "localhost", port: 6379
    subscription = new Subscription channel: "greetings", transport: transport
    transport.logger.level = "debug"

    subscription.subscribe (error,message) ->
      subscription.unsubscribe()
      callback error, message
    
    subscription.end()



  subscribe (error,message) ->
    test.assert.equal "Hello!", message?.content    
    test.done()

  # Give it a second to make sure the subscribe is set up
  setTimeout (-> publish "Hello!"), 100
  
  setTimeout (-> test.fail "Never got publish" ; process.exit() ), 1000