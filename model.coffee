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

  # occupied 
  if _.keys(game.occupied_points).indexOf(point_id) != -1
    return false

  # ko
  if game.ko_points.indexOf(point_id) != -1
    return false

  # update aux data
  res = share.updateAuxData(game, point_id)

  # move was suicide
  if not res
    return false

  # record to history
  if typeof $ != 'undefined'
    obj = $.extend(true, {}, Games.find({_id: game._id}).fetch()[0])
    delete obj._id
    $.history.push(obj)    
  
  # add stone
  stone = {
    point_id: point_id,
    player: game.current_turn,
    captured: false
  }
  game.stones.push(stone)

  # capture dead stones
  for stone in game.stones
    if res.dead_points.indexOf(stone.point_id) != -1
      game.captures[game.current_turn] += 1
      stone.captured = true

  Games.update(game._id, {$set: {stones: game.stones, captures: game.captures, groups: res.groups, occupied_points: res.occupied_points, ko_points: res.ko_points, current_turn: share.otherPlayer(game.current_turn)}})

# resign player
share.playerResign = (game, player) ->
  if game.state == "awaitingPlayer"
    Games.remove({_id:game._id})
    return false

  if game.state != "active"
    return false

  game.score.winner = share.otherPlayer(player)
  game.score.score = -1

  Games.update(game._id, {$set: {state: "completed", score: game.score}})

  # updatePlayerRecords


# player passes
share.pass = (game) ->
  if game.state != "active" && game.state != "pass"
    return false

  if game.state == "pass"
    Games.update(game._id, {$set: {state: "scoring"}})
  else
    Games.update(game._id, {$set: {state: "pass", current_turn:share.otherPlayer(game.current_turn)}})


# player requests undo
share.undo = (game) ->
  $.Games.update(game._id, {$set: {state: "requestUndo"}})


# player is done scoring
share.done = (game) ->
  if game.state == "scoring"
    #$.Games.update(game._id, {$set: {state: "partialDoneScoring"}})
    score = share.computeScore(game)
    $.Games.update(game._id, {$set: {score: game.score, state: "completed"}})
  else if game.state == "partialDoneScoring"
    score = share.computeScore(game)
    $.Games.update(game._id, {$set: {score: game.score, state: "completed"}})


# depending on game state, do something
share.clickStone = (game, point_id) ->
  if game.state != "scoring" && game.state != "partialDoneScoring"
    return

  group = game.groups[game.occupied_points[point_id]]
  group.marked_dead = !group.marked_dead

  Games.update(game._id, {$set: {groups: game.groups, state: "scoring"}})
