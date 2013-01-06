Games = new Meteor.Collection("game")
Games.remove({})
Games.insert(default_game)

if Meteor.isClient
  Template.game.points = Games.findOne().board.points
  Template.game.edges  = Games.findOne().board.edges

  Template.hello.greeting = () ->
    "Welcome to tgs."

  Template.hello.events
    'click input' : () -> 
      # template data, if any, is available in 'this'
      if typeof console != 'undefined'
        console.log "You pressed the button"

if Meteor.isServer
  Meteor.startup () ->
    #code to run on server at startup
    0 + 0
