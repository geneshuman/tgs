# EVENT HANDLERS
undo = () ->
  if !$.isCurrentTurn() && $.history.length != 0
    share.undo($.currentGame())


pass = () ->
  if $.isCurrentTurn()
    share.pass($.currentGame())


resign = () ->
  game = $.currentGame()
  if game.state == "active" && confirm("Are you sure you want to resign?")
    share.playerResign(game, $.userColor())


player_finished = false
doneScoring = () ->
  if player_finished
    return
  player_finished = true

  share.done($.currentGame())


# TEMPLATES
Template.gameConsole.blackName = () ->
  game = $.currentGame()
  player = Meteor.users.find({_id: game.players.black}).fetch()[0]
  if player
    player.username
  else
    "WAITING"


Template.gameConsole.whiteName = () ->
  game = $.currentGame()
  player = Meteor.users.find({_id: game.players.white}).fetch()[0]
  if player
    player.username
  else
    "WAITING"


Template.gameConsole.numBlackCaptures = () ->
  $.currentGame().captures.black


Template.gameConsole.numWhiteCaptures = () ->
  $.currentGame().captures.white


Template.gameConsole.currentTurnIs = (player) ->
  $.currentGame().current_turn == player


Template.gameConsole.numMoves = () ->
  $.currentGame().stones.length

Template.gameConsole.helpers {
  observingGame: () ->
    $.observingGame()  
  isState: (state) ->
    $.currentGame().state == state
  }


Template.gameConsole.events {
  'click #undoButton': undo,
  'click #passButton': pass,
  'click #resignButton': resign,
  'click #doneButton': doneScoring
}

