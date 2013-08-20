$.Games = new Meteor.Collection("game")

Meteor.startup () ->

  Template.console.games = () ->    
    $.Games.find()

  Template.console.boardTypes = () ->
    alert(share.boardTypes)

  Template.console.currentGame = () ->
    Session.get("current_game")
  
  # temporary
  $.Games.find().observeChanges {added: (id, fields) ->
    game = $.Games.find({_id: id})
    Session.set("current_game", game.fetch()[0])
  }

  Deps.autorun () ->
    game = Session.get("current_game")

    if not game
      return

    $.initScene(game)

    $.Games.find().observeChanges {changed: (id, fields) ->
      $.drawLastStone()
    }