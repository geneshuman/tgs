#
# Game
#


share.playStone = (game, point_id) ->
  game.stones.push(point_id)
  #$.Games.update(game._id, {$push: {moves: point_id}})
  $.Games.update(game._id, {stones:game.stones})
  
