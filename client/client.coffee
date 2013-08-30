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
  if $.observingGame()
    return false

  game = $.currentGame()
  return game.players[game.current_turn] == user._id


$.userColor = () ->
  game = $.currentGame()
  if game.players["black"] == Meteor.user()._id
    return "black"
  else if game.players["white"] == Meteor.user()._id
    return "white"
  else
    return null


$.observingGame = () ->
  false && Session.get("observing_game")


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
      handleStateChange()
    }

handleStateChange = () ->
  game = $.currentGame()
  if game.state == "completed"
    completeGame(game)


completeGame = (game) ->
  str = game.score.winner + " wins"

  if game.score.score == -1
    str = game.score.winner + " wins by resignation"
  else if game.winner == "tie"
    str = "Tie game"
  else
    str = game.score.winner + " wins by " + game.score.score + " points"

  if alert(str)
    Session.set("current_game_id", null)

# account config
Accounts.config({
  sendVerificationEmail: true
})
Accounts.ui.config({
  passwordSignupFields: 'USERNAME_AND_EMAIL'
})