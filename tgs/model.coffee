#
# Game
#


share.playStone = (game, point_id) ->
  # add stone
  stone = {
    point_id: point_id,
    player: game.current_turn,
    captured: false
  }
  game.stones.push(stone)

  #update turn
  if game.current_turn == 'black'
    next_turn = 'white'
  else
    next_turn = 'black'

  $.Games.update(game._id, {$set: {stones: game.stones, current_turn: next_turn}})
  

share.captureStone = (game, point_id) ->
  stone = [stone for stone in game.stones when stone.point_id == point_id and not stone.captured][0][0]
  stone.point_id = null
  stone.captured = true

  $.Games.update(game._id, {$set: {stones: game.stones}})

