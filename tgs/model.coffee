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

  if game.current_turn == 'black'
    next_turn = 'white'
  else
    next_turn = 'black'

  $.Games.update(game._id, {$set: {stones: game.stones, current_turn: next_turn}})
  $.game = $.Games.findOne() # i don't like this
  
