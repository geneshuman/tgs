$.Games = new Meteor.Collection("game")
$.BoardTypes = new Meteor.Collection("boardTypes")

# current game
$.currentGame = () ->
  id = Session.get("current_game_id")
  if not id
    return null
  $.Games.find({_id: id}).fetch()[0]

# function to create a new game
newGame = () ->
  name = $('#selectBoard').val()
  board = $.BoardTypes.find({name: name}).fetch()[0].data

  game = {
    boardType: name,
    players: {
      black: Meteor.user()._id,
      white: null
    },
    current_turn: 'black',
    stones: [],
    board: board
  }
  id = $.Games.insert(game)
  Session.set("current_game_id", id)


joinGame = (event) ->
  id = event.currentTarget.id
  game = $.Games.find({_id: id}).fetch()[0]
  players = game.players
  if !players.black
    players.black = Meteor.user()._id
  else
    players.white = Meteor.user()._id
  $.Games.update({_id: id}, {$set: {players: players}})
  Session.set("current_game_id", game._id)
  

# Templates
Template.console.games = () ->    
  $.Games.find()

Template.console.boardTypes = () ->
  $.BoardTypes.find()
  
Template.console.currentGame = () ->
  $.currentGame()

Template.console.events {
  'click #newGameButton': newGame,
  'click .joinGame': joinGame
}

Template.console.helpers {
  anyGames: () ->
    $.Games.find().fetch().length != 0
}

# startup
Meteor.startup () ->  
  Deps.autorun () ->
    game = $.currentGame()
    if not game
      return

    $.initScene(game)
    $.Games.find({_id: game._id}).observeChanges {changed: (id, fields) ->
      $.updateStones()
    }

# account config
Accounts.config({
  sendVerificationEmail: true
})
Accounts.ui.config({
  passwordSignupFields: 'USERNAME_AND_EMAIL'
})