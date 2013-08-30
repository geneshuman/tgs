Games = new Meteor.Collection("game")
BoardTypes = new Meteor.Collection("boardTypes")
Connections = new Meteor.Collection("connections")

Meteor.startup () ->
  Games.remove({})

  # load boards from server
  BoardTypes.remove({})
  types = ["2x2x2"]#, "3x3x3", "4x4x4", "5x5x5", "2x2x5", "2x2x7", "2x3x7"]

  for board in types
    data = JSON.parse(Assets.getText(board + ".json"))
    BoardTypes.insert({name: board, data:data})



# server code: heartbeat method
Meteor.methods {
  keepalive: (user_id) ->
    if (!Connections.findOne(user_id))
      Connections.insert({user_id: user_id})

    Connections.update(user_id, {$set: {last_seen: (new Date()).getTime()}})  
}


# server code: clean up dead clients after 60 seconds
#Meteor.setInterval () ->
#  now = (new Date()).getTime()
#  Connections.find({last_seen: {$lt: (now - 60 * 1000)}}).forEach (user) ->
#    5+0

    # // do something here for each idle user
