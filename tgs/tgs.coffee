if Meteor.isClient
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
