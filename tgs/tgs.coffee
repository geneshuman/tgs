Games = new Meteor.Collection("game")

if Meteor.isClient
  Template.game = ->
    Games.find({}).fetch()[0]

if Meteor.isServer
  Meteor.startup () ->
    if(Games.find().count() == 0 or true)
      Games.remove({})
      Games.insert({name: 'shiz'})
