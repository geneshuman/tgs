$.Games = new Meteor.Collection("game")

Meteor.startup () ->
  
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