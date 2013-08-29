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

# all games a user(logged in or not) can see
$.availableGames = () ->
  if Meteor.user()
    $.Games.find().fetch()
  else
    _.filter $.Games.find().fetch(), (game) ->
      game.players.white && game.players.black


Template.console.username = () ->  
  Meteor.user().username

Template.console.currentGame = () ->
  $.currentGame()

Template.console.events {
  'click .logout': () -> Meteor.logout()
}

# startup
Meteor.startup () ->
  #Meteor.logout()

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