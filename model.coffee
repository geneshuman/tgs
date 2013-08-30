#
# Game
#

share.playStone = (game, point_id) ->
  # CHECK IF MOVE IS VALID - can't be occupied, KO, or suicide, game state is correct
  if game.state != "active" && game.state != "pass"
    return false
  
  # add stone
  stone = {
    point_id: point_id,
    player: game.current_turn,
    captured: false
  }
  game.stones.push(stone)

  # update groups

  $.Games.update(game._id, {$set: {stones: game.stones, current_turn: share.otherPlayer(game.current_turn)}})


share.clickStone = (game, point_id) ->
  # depending on game status, do something
  return false


share.playerResign = (game, player) ->
  game.score.winner = share.otherPlayer(player)
  game.score.score = -1

  $.Games.update(game._id, {$set: {state: "completed", score: game.score}})


share.pass = (game) ->
  return false


share.undoLastMove = (game) ->
  return false


# out dated
share.captureStone = (game, point_id) ->
  stone = [stone for stone in game.stones when stone.point_id == point_id and not stone.captured][0][0]
  stone.point_id = null
  stone.captured = true

  captures = game.captures  
  captures[share.otherPlayer(stone.player)] += 1

  $.Games.update(game._id, {$set: {stones: game.stones, captures: captures}})

