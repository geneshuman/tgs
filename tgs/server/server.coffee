Games = new Meteor.Collection("game")

Meteor.startup () ->
  if(Games.find().count() == 0 or true)
    Games.remove({})
    Games.insert(share.default_game)