Games = new Meteor.Collection("game")

if Meteor.isClient
  Template.data.game = () ->
    return Games.findOne({})

  Template.game.points = () ->
    return Template.data.game().board.points

  Template.game.edges = () ->
    return Template.data.game().board.edges

if Meteor.isServer
  Meteor.startup () ->
    if(Games.find().count() == 0 or true)
      Games.remove({})
      Games.insert(default_game)
