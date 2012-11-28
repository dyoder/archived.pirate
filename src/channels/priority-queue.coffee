Channel = require "../channel"

class PriorityQueue extends Channel
  
  constructor: (configuration) ->
    
    super configuration
    {@priorities} = configuration
    @priorities ?= [1..5]
    @channelList = ("#{@name}.#{priority}" for priority in @priorities)
        
  enqueue: (message,priority) ->
    
    message = @envelope message
    @transport.enqueue message

  dequeue: ->
    @transport.dequeue @channelList
    
  envelope: (message) ->
    super message
    {channel,priority} = message
    message.channel = "#{channel}.#{priority}"
    message
    
    
module.exports = PriorityQueue