default_board = {
  name: 'default',
  # automatically compute this eventually
  stone_radius: 0.1,
  scale: {
    lll: [-1,-1,-1],
    uuu: [1,1,1]
  },
  points: [
    {
      point_id: 0,
      pos: [-1,-1,-1]
    },
    {
      point_id: 1,
      pos: [1,-1,-1]
    },
    {
      point_id: 2,
      pos: [1,1,-1]
    },
    {
      point_id: 3,
      pos: [-1,1,-1]
    },
    {
      point_id: 4,
      pos: [-1,-1,1]
    },
    {
      point_id: 5,
      pos: [1,-1,1]
    },
    {
      point_id: 6,
      pos: [1,1,1]
    },
    {
      point_id: 7,
      pos: [-1,1,1]
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
      connection: [3,0]
    },
    {
      edge_id: 4,
      connection: [4,5]
    },
    {
      edge_id: 5,
      connection: [5,6]
    },
    {
      edge_id: 6,
      connection: [6,7]
    },
    {
      edge_id: 7,
      connection: [7,4]
    },
    {
      edge_id: 8,
      connection: [0,4]
    },
    {
      edge_id: 9,
      connection: [1,5]
    },
    {
      edge_id: 10,
      connection: [2,6]
    },
    {
      edge_id: 11,
      connection: [3,7]
    },

  ]
}

share.default_game = {
  name: 'shiz2',
  players: [0, 1],
  moves: [],
  board: default_board
}


