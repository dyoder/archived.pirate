Queue = require "../../src/channels/queue"
Transport = require "../../src/transports/redis"

transport = new Transport host: "localhost", port: 6379
queue = new Queue channel: "greetings", transport: transport
queue.enqueue "Hello!"
queue.end()