share.Games = new Meteor.Collection("game")
BoardTypes = new Meteor.Collection("boardTypes")
Connections = new Meteor.Collection("connections")

Meteor.startup () ->
  Connections.remove({})
#  share.Games.remove({})
#  Meteor.users.remove({})

  # load boards from server
  BoardTypes.remove({})
  #types = ["2x2x2", "3x3x3", "4x4x4", "5x5x5"]#, "2x2x5", "2x2x7", "2x3x7"]
  types = ["4x4x4s1","5x5x5s1","6x6x6s1","7x7x7s1","5x5x5s2","6x6x6s2","7x7x7s2","7x7x7s3","9x9x1","3x3x3","4x4x4","5x5x5","6x6x6","7x7x7","5x2x2","6x2x2","7x2x2","5x2x3","6x2x3","7x2x3","5x2x4","7x2x4","5x2x5","7x2x7","9x2x9","5x3x3","7x3x3","9x3x3","7x3x5","5x3x5","7x3x7","9x3x9"]

  for board in types
    data = JSON.parse(Assets.getText(board + ".json"))
    BoardTypes.insert({name: board, data:data})


# server code: heartbeat method
Meteor.methods {
  keepalive: (user_id, game_id) ->
    console.log "keepalive", user_id, game_id
    if !Connections.find({user_id: user_id, game_id: game_id}).fetch()[0]
      Connections.insert({user_id: user_id, game_id: game_id})

    Connections.update({user_id: user_id, game_id: game_id}, {$set: {last_seen: (new Date()).getTime()}})  
}


# server code: clean up dead clients after 60 seconds
Meteor.setInterval((() ->
  now = (new Date()).getTime()
  Connections.find({last_seen: {$lt: (now - 60 * 1000)}}).fetch().forEach (con) ->
    game = share.Games.findOne({_id: con.game_id})
    user = Meteor.users.findOne({_id: con.user_id})
    console.log "missing user", game._id, user._id
    Connections.remove({user_id:user._id, game_id: game._id})
    if game && game.state != "completed"
      if game.players.black == user._id
        share.playerResign(game, "black")
      else
        share.playerResign(game, "white")
      
  ), 1000)



# account config
Accounts.config({
  sendVerificationEmail: true
})

Accounts.onCreateUser (options, user) ->
  user.profile = {record: {wins:0, losses:0}}
  return user
