$.Games = new Meteor.Collection("game")
Meteor.startup () ->
  
  # temporary
  $.Games.find().observeChanges {added: (id, fields) ->
    game = $.Games.find({_id: id})
#    Session.set("current_game", game)
    $.initScene(game.fetch()[0])
  }

  Deps.autorun () ->
    game = Session.get("current_game")
    if game
      $.initScene(game.fetch()[0])
  

#    $.Games.find().observeChanges {added: (id, fields) ->
#      $.initScene($.Games.find({_id: id}).fetch()[0])
#    }

