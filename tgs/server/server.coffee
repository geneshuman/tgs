Games = new Meteor.Collection("game")

Meteor.startup () ->
  if(Games.find().count() == 0 or true)

    board = JSON.parse(Assets.getText("2x2x2.json"))
    game = {
      name: 'shiz2',
      players: [],
      moves: [],
      board: board
    }

    Games.remove({})
    Games.insert(game)