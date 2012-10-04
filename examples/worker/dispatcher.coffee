Messenger = require "../../src/messenger"
Transport = require "../../src/transports/redis"

messenger = new Messenger "dispatcher", new Transport host: "localhost", port: 6379
queue = messenger.queue "greetings"
queue.enqueue "Hello!"
queue.end()