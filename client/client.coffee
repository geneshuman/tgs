board_initialized = false


# data
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
  if not user
    user = Meteor.user()
  if $.observingGame()
    return false

  game = $.currentGame()
  return game.players[game.current_turn] == user._id


# color of a given user
$.userColor = (user) ->
  if not user
    user = Meteor.user()

  game = $.currentGame()
  if game.players["black"] == user._id
    return "black"
  else if game.players["white"] == user._id
    return "white"
  else
    return null


# is the game being observed or played
$.observingGame = () ->
  false && Session.get("observing_game")


# top level interaction
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

    # initialize board
    if not board_initialized
      $.initScene(game)
      board_initialized = true

      # add stones to board manually to generate aux data
      for stone in game.stones
        share.playStone(game, stone.point_id, true)

      $.updateStones()

    # game change observers
    $.Games.find({_id: game._id}).observeChanges {changed: (id, fields) ->
      $.updateStones()

      if "state" in fields
        handleStateChange()
    }


# handle game state changes
handleStateChange = () ->
  game = $.currentGame()
  if game.state == "completed"
    completeGame(game)


# game over logic
completeGame = (game) ->
  str = game.score.winner + " wins"

  if game.score.score == -1
    str = game.score.winner + " wins by resignation"
  else if game.winner == "tie"
    str = "Tie game"
  else
    str = game.score.winner + " wins by " + game.score.score + " points"

  alert(str)

  Session.set("current_game_id", null)
  $.clearScene()
  board_initialized = false




# account config
Accounts.config({
  sendVerificationEmail: true
})
Accounts.ui.config({
  passwordSignupFields: 'USERNAME_AND_EMAIL'
})