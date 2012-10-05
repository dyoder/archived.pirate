# Pirate

Pirate is a tuple-space-based messaging transport. (Say that three times fast!) What does that mean? That's kind of long story, but the short version is that you use some kind of scalable storage as the message transport instead of using straight sockets.

## But ... Why?

Why is that useful? That's a long story, but the short version is that you get simpler and more robust messaging. Reliable messaging, for example, comes for free (more or less).

Pirate also provides (or will provide) a catalog of common messaging patterns on top of the transport layer, to make it very easy to implement things like map-reduce or pipe-and-filter.

## Status

Pirate is definitely a work in progress. 

Presently, one transport (Redis, doing a nice job of pretending to be a DHT), three messaging channels (simple messaging, queues, pub-sub), and one messaging pattern (request-reply) are supported.

## Installation

Coming soon.

## Examples

Check out the `examples/worker` example, which has a "dispatcher" sending a message to a "worker". Not terribly realistic, I realize, but, hey, did you see what I said about the [project status][status]?

[status]: #Status