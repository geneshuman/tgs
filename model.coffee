#
# Game
#

if typeof $ != 'undefined'
  Games = $.Games
else
  Games = share.Games

share.playStone = (game, point_id) ->
  # correct game state
  if game.state != "active" && game.state != "pass"
    return false

  # occupied or ko
  if point_id in game.occupied_points or point_id in ko_points
    return false

  # update aux data
  dead_points = $.updateAuxData(game, point_id)

  # move was suicide
  if not dead_points
    return false  
  
  # add stone
  stone = {
    point_id: point_id,
    player: game.current_turn,
    captured: false
  }
  game.stones.push(stone)

  # capture dead stones
  for stone in game.stones
    if indexOf(dead_points, stone.point_id) != -1
      stone.captured = true

  Games.update(game._id, {$set: {stones: game.stones, current_turn: share.otherPlayer(game.current_turn)}})


share.clickStone = (game, point_id) ->
  # depending on game status, do something
  return false


share.playerResign = (game, player) ->
  if game.state != "active"
    return false

  game.score.winner = share.otherPlayer(player)
  game.score.score = -1

  Games.update(game._id, {$set: {state: "completed", score: game.score}})

  # updatePlayerRecords


share.pass = (game) ->
  if game.state != "active" && game.state != "pass"
    return false

  if game.state == "pass"
    Games.update(game._id, {$set: {state: "scoring"}})
  else
    Games.update(game._id, {$set: {state: "pass", current_turn:share.otherPlayer(game.current_turn)}})


share.undoLastMove = (game) ->
  return false


# out dated
share.captureStone = (game, point_id) ->
  stone = [stone for stone in game.stones when stone.point_id == point_id and not stone.captured][0][0]
  stone.point_id = null
  stone.captured = true

  captures = game.captures  
  captures[share.otherPlayer(stone.player)] += 1

  Games.update(game._id, {$set: {stones: game.stones, captures: captures}})

