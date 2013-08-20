Games = new Meteor.Collection("game")

BoardTypes = new Meteor.Collection("boardTypes")

Meteor.startup () ->
#  Games.remove({})
  # load boards from server
  BoardTypes.remove({})
  types = ["2x2x2", "3x3x3", "4x4x4", "5x5x5", "2x2x5", "2x2x7", "2x3x7"]

  for board in types
    data = JSON.parse(Assets.getText(board + ".json"))
    BoardTypes.insert({name: board, data:data})