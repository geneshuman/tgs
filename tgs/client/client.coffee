$.Games = new Meteor.Collection("game")
$.BoardTypes = new Meteor.Collection("boardTypes")

# function to create a new game
newGame = () ->
  name = $('#selectBoard').val()
  board = $.BoardTypes.find({name: name}).fetch()[0].data

  game = {
    boardType: name,
    players: {},
    stones: [],
    board: board
  }
  id = $.Games.insert(game)
  Session.set("current_game", $.Games.find({_id: id}).fetch()[0])

# Templates
Template.console.games = () ->    
  $.Games.find()

Template.console.boardTypes = () ->
  $.BoardTypes.find()
  
Template.console.currentGame = () ->
  Session.get("current_game")

Template.console.events {
  'click #newGameButton': newGame
}

Template.console.helpers {
  anyGames: () ->
    $.Games.find().fetch().length != 0
}

# startup
Meteor.startup () ->  
  Deps.autorun () ->
    game = Session.get("current_game")

    if not game
      return

    $.initScene(game)
    $.Games.find({_id: game._id}).observeChanges {changed: (id, fields) ->
      $.drawLastStone()
    }

# account config
Accounts.config({
  sendVerificationEmail: true
})
Accounts.ui.config({
  passwordSignupFields: 'USERNAME_AND_EMAIL'
})