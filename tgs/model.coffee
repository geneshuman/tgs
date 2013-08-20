#
# Game
#


share.playStone = (game, point_id) ->  
  stone = {
    point_id: point_id,
    player: game.current_turn,
    captured: false
  }
  game.stones.push(stone)
  #$.Games.update(game._id, {$push: {moves: point_id}})
  $.Games.update(game._id, {$set: {stones: game.stones}})
  #console.log $.Games.findOne()
  
