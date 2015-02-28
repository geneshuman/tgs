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
  Session.get("observing_game")


# top level interaction
Template.console.helpers {
  username: () ->
    Meteor.user().username
  currentGame: () ->
    $.currentGame()
}


Template.console.events {
  'click #titleDropDown': (event) ->
    event.preventDefault()
  'click .logout': () ->
    if $.currentGame()
      share.playerResign($.currentGame(), $.userColor())
    Meteor.logout()
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

      # game aux data
      share.initClientAuxData(game)

      # size chat window
      $.sizeChatWindow()

    # game change observers
    $.Games.find({_id: game._id}).observe {changed: (new_doc, old_doc) ->
      if new_doc.stones.length > old_doc.stones.length
        $('#click')[0].volume = 0.3
        $('#click')[0].play()
  
      $.updateStones()
      if old_doc.state != new_doc.state
        handleStateChange(new_doc, old_doc)
    }


# handle game state changes
handleStateChange = (new_doc, old_doc) ->
  game = $.currentGame()
  console.log new_doc.state, old_doc.state
  if new_doc.state == "active" && old_doc.state == "awaitingPlayer"
    $('#join_chime')[0].play()
  else if new_doc.state == "completed"    
    completeGame(game)
  else if new_doc.state == "requestUndo"
    console.log "requestUndo"
    if $.isCurrentTurn()
      if confirm("Your opponent has requested to undo their last move")        
        $.Games.update(Session.get("current_game_id"), {$set: {state: "acceptUndo"}})
      else
        $.Games.update(Session.get("current_game_id"), {$set: {state: "active"}})
  else if new_doc.state == "acceptUndo"
    if !$.isCurrentTurn()
      alert("Request accepted")      
      $.Games.update(Session.get("current_game_id"), {$set: $.history.pop()})
      $.updateStones()  # <------- why is this necessary?
  else if new_doc.state == "active" && old_doc.state == "requestUndo"
    if new_doc.stones.length == old_doc.stones.length
      if !$.isCurrentTurn()
        alert("Request denied")


# game over logic
completeGame = (game) ->  
  str = game.score.winner + " wins"
  if game.score.score == -1
    str = game.score.winner + " wins by resignation"
  else if game.score.score == 0
    str = "Tie game"
  else   
    str = game.score.winner + " wins by " + game.score.score + " points"

  alert(str)  

  Session.set("current_game_id", null)
  $.clearScene()
  board_initialized = false


# account ui config
Accounts.ui.config({
  passwordSignupFields: 'USERNAME_AND_EMAIL'
})

# keep alive code
Meteor.setInterval((() ->
  if $.currentGame()
    Meteor.call('keepalive', Meteor.userId(), Session.get("current_game_id"))),
  2500)
