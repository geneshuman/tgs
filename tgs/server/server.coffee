Games = new Meteor.Collection("game")

BoardTypes = new Meteor.Collection("boardTypes")

Meteor.startup () ->  
  # load boards from server
  BoardTypes.remove({})
  types = ["2x2x2"]

  for board in types
    data = JSON.parse(Assets.getText(board + ".json"))
    BoardTypes.insert({name: board, data:data})