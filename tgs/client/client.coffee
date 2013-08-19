$.Games = new Meteor.Collection("game")

game_observer = null

Meteor.startup () ->  
  # temporary
  $.Games.find().observeChanges {added: (id, fields) ->
    game = $.Games.find({_id: id})
    Session.set("current_game", game.fetch()[0])
#    
#    alert(2)
  }

  Deps.autorun () ->
    game = Session.get("current_game")

    if not game
      return

    $.initScene(game)

    if game_observer
      game_observer.stop()
  
    game_observer = $.Games.find({_id: game._id}).observeChanges {changed: (id, fields) ->
      alert(1)
      $.drawLastStone()
    }


#    $.Games.find().observeChanges {added: (id, fields) ->
#      $.initScene($.Games.find({_id: id}).fetch()[0])
#    }

