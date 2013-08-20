$.Games = new Meteor.Collection("game")
$.BoardTypes = new Meteor.Collection("boardTypes")

newGame = () ->
  name = $('#selectBoard').val()
  board = $.BoardTypes.find({name: name}).fetch()[0].data

  game = {
    name: name,
    players: [],
    stones: [],
    board: board
  }
  $.Games.insert(game)
  Session.set("current_game", game)

Template.console.games = () ->    
  $.Games.find()

Template.console.boardTypes = () ->
  $.BoardTypes.find()
  
Template.console.currentGame = () ->
  Session.get("current_game")

Template.console.events {
  'click #newGameButton': newGame
}


Meteor.startup () ->  
  Deps.autorun () ->
    game = Session.get("current_game")

    if not game
      return

    $.initScene(game)

    $.Games.find({_id: game._id}).observeChanges {changed: (id, fields) ->
      alert(1)
      $.drawLastStone()
    }


