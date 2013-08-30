# all games a user(logged in or not) can see
availableGames = () ->
  if Meteor.user()
    $.Games.find().fetch()
  else
    _.filter $.Games.find().fetch(), (game) ->
      game.players.white && game.players.black

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
    state: "awaitingPlayer", # awaitingPlayer -> active -> requestUndo -> pass -> scoring -> completed
    captures: {
      black: 0,
      white: 0
    }
    score: {
      winner: null, # 'black', 'white', or 'tie'
      score: null # number or -1 for resign
    }
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
  $.Games.update({_id: id}, {$set: {players: players, state: 'active'}})
  Session.set("current_game_id", game._id)

# observe an existing game
observeGame = (event) ->
  id = event.currentTarget.id
  game = $.Games.find({_id: id}).fetch()[0]
  Session.set("current_game_id", game._id)
  Session.set("observing_game", true)
  
# Templates
Template.lobbyConsole.availableGames = () ->
  availableGames()

Template.lobbyConsole.username = () ->  
  Meteor.user().username

Template.lobbyConsole.boardTypes = () ->
  $.BoardTypes.find()

Template.lobbyConsole.helpers {
  anyGames: () ->
    availableGames().length != 0
}

Template.gameSummary.helpers {
  black: () ->
    user = Meteor.users.find({_id: this.players.black}).fetch()[0]
    if user
      user.username
    else
      ""
  ,white: () ->
    user = Meteor.users.find({_id: this.players.white}).fetch()[0]
    if user
      user.username
    else
      ""
  ,moves: () ->
    this.stones.length
  ,available: () ->
    !this.players.black || !this.players.white
}

Template.lobbyConsole.events {
  'click #newGameButton': newGame,
  'click .joinGame': joinGame,
  'click .observeGame': observeGame,
}