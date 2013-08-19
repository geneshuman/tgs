default_board = {
  points: [
    {
      point_id: 0,
      pos: [0,0,0]
    },
    {
      point_id: 1,
      pos: [1,0,0]
    },
    {
      point_id: 2,
      pos: [0,1,0]
    },
    {
      point_id: 3,
      pos: [1,1,0]
    }
  ],

  edges: [
    {
      edge_id: 0,
      connection: [0,1]
    },
    {
      edge_id: 1,
      connection: [1,2]
    },
    {
      edge_id: 2,
      connection: [2,3]
    },
    {
      edge_id: 3,
      connection: [3,1]
    }
  ]
}

default_game = {
  name: 'shiz2',
  players: [0, 1],
  moves: [],
  board: default_board
}


