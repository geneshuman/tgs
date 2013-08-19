$.Games = new Meteor.Collection("game")
  # Template.data.game = () ->
  #   return Games.findOne({})

  # Template.game.points = () ->
  #   return Template.data.game().board.points

  # Template.game.edges = () ->
  #   return Template.data.game().board.edges

  # Template.getGame = () ->
  #   return Games.findOne({})
# 
#Template.game.rendered = () ->
#  $.initScene(Games.findOne({}))


Meteor.startup () ->
  Deps.autorun () ->
    $.Games.find().observeChanges {added: (id, fields) ->
      console.log "added game"
      $.initScene($.Games.find({_id: id}))
    }

 #     Session.set("current_game", Games.findOne({})._id)


#Meteor.subscripe("currentGame")