if typeof $ != 'undefined'
  Games = $.Games
else
  Games = share.Games


# build aux data from scratch
share.initAuxData = (game) ->
  game.occupied_points = {}
  game.ko_points = {}
  game.groups = {}
  for stone in game.stones
    share.updateAuxData(game, stone.point_id)


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
    liberties: liberties
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