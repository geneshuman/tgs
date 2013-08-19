Games = new Meteor.Collection("game")
console.log(2)

Meteor.startup () ->
  if(Games.find().count() == 0 or true)
    Games.remove({})
    Games.insert(default_game)

#Meteor.publish("currentGame", () ->
#  Games.findOne()
#)