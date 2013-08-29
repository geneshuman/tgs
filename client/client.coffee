board_initialized = false

$.Games = new Meteor.Collection("game")
$.BoardTypes = new Meteor.Collection("boardTypes")

# current game
$.currentGame = () ->
  id = Session.get("current_game_id")
  if not id
    return null
  $.Games.find({_id: id}).fetch()[0]

# is current turn
$.isCurrentTurn = (user) ->
  if Session.get("observing_game")
    return false 
  game = $.currentGame()
  for color, id of game.players
    if id == user._id
      return color == game.current_turn     

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
    captured_stones: [],
    board: board
  }
  id = $.Games.insert(game)
  Session.set("current_game_id", id)

# join an existing game
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

# observe an existing game
observeGame = (event) ->
  id = event.currentTarget.id
  game = $.Games.find({_id: id}).fetch()[0]
  Session.set("current_game_id", game._id)
  Session.set("observing_game", true)
  

# Templates
Template.console.games = () ->    
  $.Games.find()

Template.console.boardTypes = () ->
  $.BoardTypes.find()
  
Template.console.currentGame = () ->
  $.currentGame()

Template.console.events {
  'click #newGameButton': newGame,
  'click .joinGame': joinGame,
  'click .observeGame': observeGame
}

Template.console.helpers {
  anyGames: () ->
    $.Games.find().fetch().length != 0
}

Template.gameSummary.helpers {
  black: () ->
    user = Meteor.users.find({_id: this.players.black}).fetch()[0]
    if user
      user.username
    else
      "None"
  ,white: () ->
    user = Meteor.users.find({_id: this.players.white}).fetch()[0]
    if user
      user.username
    else
      "None"
  ,moves: () ->
    this.stones.length
  ,available: () ->
    !this.players.black || !this.players.white
}

# startup
Meteor.startup () ->  
  Deps.autorun () ->
    game = $.currentGame()
    if not game 
      return

    if not board_initialized
      $.initScene(game)
      board_initialized = true

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