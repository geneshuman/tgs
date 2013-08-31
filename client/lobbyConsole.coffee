# all games a user(logged in or not) can see
availableGames = () ->
  if Meteor.user()
    $.Games.find({state: {$ne: "completed"}}).fetch()
  else
    _.filter $.Games.find({state: {$ne: "completed"}}).fetch(), (game) ->
      game.players.white && game.players.black


# function to create a new game
newGame = () ->
  name = $('#selectBoard').val()
  board = $.BoardTypes.find({name: name}).fetch()[0].data

  game = {
    boardType: name,
    players: {
      black: Meteor.user()._id,
      white: null #Meteor.user()._id
    },
    current_turn: 'black',
    stones: [],
    state: "awaitingPlayer", # awaitingPlayer -> active -> requestUndo -> pass -> scoring -> partialDoneScoring -> completed
    captures: {
      black: 0,
      white: 0
    }
    score: {
      winner: null, # 'black', 'white', or 'tie'
      score: null, # number or -1 for resign
      black: 0,
      white: 0
    }
    occupied_points:{},
    ko_points:[],
    groups:{},
    board: board,
    player_chats: [],
    observer_chats: []
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
  $.BoardTypes.find({}, {sort: {name:1}})

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
  ,gameRecord: (game_id, player) ->
    game = $.Games.findOne(game_id)
    u = Meteor.users.find({_id:game.players[player]}).fetch()[0]
    if not u
      return ""
    #console.log u
    w = u.profile.record.wins
    l = u.profile.record.losses
    "#{w} wins/ #{l} losses (#{Math.round(100.0 * w/(w+l))}%)"
}

Template.lobbyConsole.events {
  'click #newGameButton': newGame,
  'click .joinGame': joinGame,
  'click .observeGame': observeGame,
}