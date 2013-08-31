if typeof $ != 'undefined'
  Games = $.Games
else
  Games = share.Games


# build aux data from scratch
share.initClientAuxData = (game) ->
  $.history = []


# update aux data for a specific point
# return false for suicide
# else return list of killed groups
share.updateAuxData = (game, point_id) ->  
  neighbors = game.board.points[point_id].neighbors

  # copy neighbors
  liberties = neighbors.slice(0)
  if liberties.length == 0
    return false

  # get all neighboring groups
  $.fr = friend_groups = {}
  $.en = enemy_groups = {}
  for id in neighbors
    if !game.occupied_points[id]
      continue
    group_id = game.occupied_points[id]
    group = game.groups[group_id]
    if group.player == game.current_turn
      if friend_groups[group_id]          
        friend_groups[group_id].push(id)
      else
        friend_groups[group_id] = [id]
    else
      if enemy_groups[group_id]          
        enemy_groups[group_id].push(id)
      else
        enemy_groups[group_id] = [id]

    liberties = _.without(liberties, id)

  # reduce liberties of enemy groups
  dead_points = []
  for group_id, point_ids of enemy_groups
    group = game.groups[group_id]
    group.liberties = _.without(group.liberties, point_id)

    # kill group
    if group.liberties.length != 0
      continue
    dead_points = _.union(dead_points, group.members)
    liberties = _.union(liberties, point_ids)

    # update liberties of neighboring groups
    neighbor_groups = {}
    for member in group.members
      neighbors = game.board.points[member].neighbors
      for neighbor in neighbors
        n_group_id = game.occupied_points[neighbor]
        if !n_group_id || n_group_id == group_id
          continue
                
        if neighbor_groups[n_group_id]
          neighbor_groups[n_group_id].push(member)
        else
          neighbor_groups[n_group_id] = [member]

      # remove point    
      delete game.occupied_points[member]
  
    for n_group_id, lib of neighbor_groups
      n_group = game.groups[n_group_id]
      n_group.liberties = _.union(n_group.liberties, lib)

    delete game.groups[group_id]
    # check for ko      

  # merge friendly groups
  members = [point_id]
  for group_id, point_ids of friend_groups
    group = game.groups[group_id]
    members = _.union(members, group.members)
    liberties = _.union(liberties, group.liberties)
    delete game.groups[group_id]

  liberties = _.difference(liberties, members)
  group = {
    id: Random.id(),
    player: game.current_turn,    
    members: members,
    liberties: liberties,
    marked_dead: false
  }
  game.groups[group.id] = group

  # update occupied points
  for member in members
    game.occupied_points[member] = group.id

  # is suicide
  if liberties.length == 0
    return false

  # check for ko
  if liberties.length == 1 && _.isEqual(dead_points,liberties)
    game.ko_points.push(liberties[0])
  else
    game.ko_points = []    

  # update aux data
  Games.update(game._id, {$set: {}})

  return {dead_points: dead_points, groups: game.groups, occupied_points: game.occupied_points, ko_points: game.ko_points}


# calculate the score
share.computeScore = (game) ->
  if game.score.winner
    return game.score

  # remove dead stones
  for id, group of game.groups
    if !group.marked_dead
      continue

    game.captures[share.otherPlayer(group.player)] += group.members.length
    for point_id in group.members
      delete game.occupied_points[point_id]

  # flood fill to compute score
  unocc = {}
  for pt in _.keys(game.board.points)
    if !game.occupied_points[pt]
      unocc[pt] = true

  regions = []

  # recursively fill a region
  floodFill = (region, unexp) ->
    # nothing more to explore
    if _.size(unexp) == 0
      return

    # find an unexplored point
    cur = _.keys(unexp)[0]
    delete unexp[cur]

    # iterate over it's neighbors
    neighbors = game.board.points[cur].neighbors
    for point_id in neighbors

      # already taken care of
      if region.members[point_id]
        continue
      
      if game.occupied_points[point_id]
        player = game.groups[game.occupied_points[point_id]].player
        if not region.owner
          region.owner = player
        else if region.owner != player
          region.owner = "dame"
      else
        unexp[point_id] = true
        region.members[point_id] = true
        region.size += 1
        delete unocc[point_id]

    floodFill(region, unexp)
      
  # start new regions
  while _.size(unocc) != 0
    cur = _.keys(unocc)[0]
    delete unocc[cur]

    current_region = {
      owner: null,
      members: {},
      size: 1
    }
    current_region.members[cur] = true

    regions.push(current_region)

    floodFill(current_region, $.extend({}, current_region.members))

  $.r = regions

  # add regions
  for region in regions
    if region.owner == "black"
      game.score.black += region.size
    else if region.owner == "white"
      game.score.white += region.size

  # compute total
  b_total = game.score.black + game.captures.black
  w_total = game.score.white + game.captures.white

  # compute winner
  if b_total > w_total
    game.score.winner = "black"
  else if b_total < w_total
    game.score.winner = "white"

  game.score.score = Math.abs(b_total - w_total)

  # black
  black = Meteor.users.findOne({_id: game.players.black})
  if not black.profile.record[game.board.name]
    black.profile.record[game.board.name] = {
      wins: 0,
      losses: 0,
      played: []
    }

  if game.score.winner == "black"
    black.profile.record[game.board.name].wins += 1
    black.profile.record.wins += 1
  else if game.score.winner == "white"
    black.profile.record[game.board.name].losses += 1
    black.profile.record.losses += 1
  black.profile.record[game.board.name].played.push(game._id)

  Meteor.users.update(Meteor.userId(), {$set: {"profile.record": black.profile.record}})

  # white
  white = Meteor.users.findOne({_id: game.players.white})

  if not white.profile.record[game.board.name]
    white.profile.record[game.board.name] = {
      wins: 0,
      losses: 0,
      played: []
    }

  if game.score.winner == "white"
    white.profile.record[game.board.name].wins += 1
    white.profile.record.wins += 1
  else if game.score.winner == "black"
    white.profile.record[game.board.name].losses += 1
    white.profile.record.losses += 1
  white.profile.record[game.board.name].played.push(game._id)

  Meteor.users.update(game.players.white, {$set: {"profile.record": white.profile.record}})


  return game.score