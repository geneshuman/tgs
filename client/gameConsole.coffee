undo = () ->
  alert(1)
  if !$.isCurrentTurn()
    return

pass = () ->
  if !$.isCurrentTurn()
    return

resign = () ->
  game = $.currentGame()
  if game.state == "active" && confirm("Are you sure you want to resign?")
    share.playerResign(game, $.userColor())


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
  }


Template.gameConsole.events {
  'click #undoButton': undo,
  'click #passButton': pass,
  'click #resignButton': resign
}

