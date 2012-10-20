# Pirate

Pirate is a tuple-space-based messaging transport. (Say that three times fast!) What does that mean? That's kind of long story, but the short version is that you use some kind of scalable storage as the message transport instead of using straight sockets.

## But ... Why?

Why is that useful? That's a long story, but the short version is that you get simpler and more robust messaging. Reliable messaging, for example, comes for free (more or less).

Pirate also provides (or will provide) a catalog of common messaging patterns on top of the transport layer, to make it very easy to implement things like map-reduce or pipe-and-filter.

## Status

Pirate is definitely a work in progress. 

### Transports

* Redis (doing a nice job of pretending to be a DHT)

### Channels

Channels take a transport and construct a specific type of communication channel.

* Send/receive
* Enqeue/dequeue
* Publish/subscribe

### Patterns

Patterns are built on top of channels, adding more sophisticated processing (example: timeouts).

* Request/reply
* Dispatcher/worker

## Installation

Coming soon.

## Examples

Let's create a simple dispatcher/worker system. Our worker will take a name and then turn it into a simple greeting. The dispatcher will get the response back with the greeting.

First, let's create our dispatcher:

    Transport = require "pirate/transports/redis"
    Dispatcher = require "pirate/channels/composite/worker/dispatcher"

    transport = new Transport host: "localhost", port: 6379
    dispatcher = new Dispatcher transport: transport, name: "greetings"

    # Define a generic result handler ...
    dispatcher.on "greetings.*.result", (result) ->
      console.log result
      
    # Same thing with the error handler ...
    dispatcher.on "*.error", (error) -> console.log error

    # Send a request!
    dispatcher.request "Dan"
      
The `greetings.*.result` business uses an event bus that takes wild-cards, so you can zero in on specific messages, or just provide generic result handler, as we've done here.

Okay, now for our worker:

    Transport = require "pirate/transports/redis"
    Worker = require "pirate/channels/composite/worker/worker"

    # This needs to be the same as in the dispatcher
    transport = new Transport host: "localhost", port: 6379
    worker = new Worker transport: transport, name: "greetings"
    
    # Define a generic task handler ... result is a function that we can use 
    # to return a result
    worker.on "greetings.*.task", (task,result) ->
      result "Hello #{task.content}!"
    
    # Generic error handler, just as above ...
    worker.on "*.error", (error) -> console.log error
    
    worker.accept()
      
That's it! Notice that the only physical endpoint is specified when creating the Transport. The `channel` endpoint is a purely logical one. Any worker listening on this channel can get tasks, and no two workers will get the same task. Similarly, any number of dispatchers can be sending tasks.
