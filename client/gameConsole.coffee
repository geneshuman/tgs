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


submitChat = (event) ->
  if event.keyCode != 13
    return

  val = $(event.target).val()
  if val.length==0
    return

  $(event.target).val("")
  game = $.currentGame()
  chat = {user_id: Meteor.userId(), chat: val}
  if $.observingGame()
    game.observer_chats.push(chat)
  else
    game.player_chats.push(chat)

  $.Games.update(game._id, {$set: {observer_chats: game.observer_chats, player_chats: game.player_chats}})  


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

Template.chatWindow.chats = () ->
  if $.observingGame()
    $.currentGame().observer_chats
  else
    $.currentGame().player_chats

Template.chatWindow.helpers {
  loggedIn: () ->
    !!Meteor.user()
  }

Template.chatWindow.rendered = () ->
  $.sizeChatWindow()
  $("#chatWindow").scrollTop($("#chatWindow")[0].scrollHeight)#   animate({ scrollTop:  - $("#chatWindow").scrollTop()}, 1000);

Template.chat.helpers {
  username: () ->
    $.id =this.user_id
    Meteor.users.find({_id:this.user_id}).fetch()[0].username
  chat: () ->
    this.chat
  }

Template.gameConsole.helpers {
  observingGame: () ->
    $.observingGame()
  isState: (state) ->
    $.currentGame().state == state
  gameStatus: () ->
    game = $.currentGame()
    if game.state == "awaitingPlayer"
      "Waiting for opponent"
    else if game.state == "active"
      "#{game.current_turn} to play"
    else if game.state == "requestUndo"
      "Undo requested"
    else if game.state == "pass"
      "Pass"
    else if game.state == "scoring" || game.state == "partialDoneScoring"
      if $.observingGame()
        "Scoring game"
      else
        "Select dead groups"
  }


Template.gameConsole.events {
  'click #undoButton': undo,
  'click #passButton': pass,
  'click #resignButton': resign,
  'click #doneButton': doneScoring,
  'keyup #chatText': submitChat
}


# resize chat window
$.sizeChatWindow = () ->
  h = $(window).height() - $('#title').outerHeight() - $('#gameConsole').outerHeight() - $('#chatInput').outerHeight()
  $('#chatWindow').height(h)


$(window).resize () ->
  $.sizeChatWindow()