Messenger = require "../../src/messenger"
Transport = require "../../src/transports/redis"

messenger = new Messenger "publisher", new Transport host: "localhost", port: 6379
subscription = messenger.subscription "greetings"
subscription.publish "Hello!"
subscription.end()