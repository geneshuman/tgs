#
# Game
#


share.playStone = (game, point_id) ->
  game.moves.push(point_id)
  #$.Games.update(game._id, {$push: {moves: point_id}})
  $.Games.update(game._id, {moves:game.moves})
  
