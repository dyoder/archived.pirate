Connector = require "../connector"

class Messenger extends Connector
  
  constructor: (configuration) ->
    super configuration
    @channel = "messenger.#{@channel}"
    
  send: (message,callback) ->
    @transport.send (@enrich message)
    @transport.bus.once "transport.send.#{message.id}.success", ->
      @bus.send "messenger.send.#{message.id}.success"
    @transport.bus.once "transport.send.#{message.id}.error", ->
      @bus.send "messenger.send.#{message.id}.error"

  receive: (callback) ->
    @transport.receive @channel
    @transport.bus.once "transport.receive.#{message.id}.success", ->
      @bus.send "messenger.receive.#{message.id}.success"
    @transport.bus.once "transport.receive.#{message.id}.error", ->
      @bus.send "messenger.receive.#{message.id}.error"
    
      
module.exports = Messenger