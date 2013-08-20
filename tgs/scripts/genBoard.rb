class Node
  attr_accessor :x, :y, :z, :id
  def initialize(x,y,z,id)
    @x=x;@y=y;@z=z;@id=id
  end
end


class Edge
  attr_accessor :n0, :n1, :id
  def initialize(n0,n1, id)
    @n0=n0;@n1=n1;@id=id;
  end
end


class Board

  attr_accessor :nodes, :edges, :name, :scale

  def initialize(name)
    @name = name
    @nodes = []
    @edges = []
    @scale = 1.0
  end

  def addNode(x, y, z)
    @nodes << Node.new(x,y,z,@nodes.length)
  end

  def addEdge(n0, n1)
    return if connected?(n0, n1) || n0 == n1
    @edges << Edge.new(n0, n1, @edges.length)
  end

  def connected?(n0, n1)
    @edges.map{|e| (e.n0 == n0 && e.n1 == n1) || (e.n0 == n1 && e.n1 == n0)}.any?
  end

  def nodeAt(x, y, z)
    @nodes.select{|n| n.x == x && n.y == y && n.z == z}.first
  end

  def normalize()
    min_x = @nodes.map{|n| n.x}.min
    min_y = @nodes.map{|n| n.y}.min
    min_z = @nodes.map{|n| n.z}.min

    max_x = @nodes.map{|n| n.x}.max
    max_y = @nodes.map{|n| n.y}.max
    max_z = @nodes.map{|n| n.z}.max

    dx = max_x - min_x
    dy = max_y - min_y
    dz = max_z - min_z

    dmax = [dx, dy, dz].max

    @scale = 1.0 / dmax

    @nodes.each do |n|
      n.x -= dx / 2.0
      n.y -= dy / 2.0
      n.z -= dz / 2.0

      n.x = 2.0 * n.x / dmax
      n.y = 2.0 * n.y / dmax
      n.z = 2.0 * n.z / dmax
    end
  end

  def write()
    str = "
{
  \"name\": \"#{@name}\",
  \"stone_radius\": #{0.3 * @scale},
  \"scale\": {
    \"lll\": [-1,-1,-1],
    \"uuu\": [1,1,1]
  },
  \"points\": [
"
    str += @nodes.map{|n| "{\n\"point_id\":#{n.id},\n\"pos\":[#{n.x},#{n.y},#{n.z}]\n}"}.join(",\n")
    str += "],\n\"edges\": [\n"
    str += @edges.map{|e| "{\n\"edge_id\":#{e.id},\n\"connection\":[#{e.n0.id},#{e.n1.id}]\n}"}.join(",\n")
    str +="\n]\n}"
    
    File.open(@name + ".json", 'w'){|f| f.write(str)}
  end

end


def genBoardNMK(n, m, k)
  board = Board.new("#{n}x#{m}x#{k}")

  (0...n).each do |x|
    (0...m).each do |y|
      (0...k).each do |z|
        board.addNode(x, y, z)
      end
    end
  end

  (0...n).each do |x|
    (0...m).each do |y|
      (0...k).each do |z|
        n0 = board.nodeAt(x, y, z)
        (0..2).each do |idx|
          [-1, 1].each do |ofs|
            c = [x, y, z]
            c[idx] += ofs
            n1 = board.nodeAt(c[0], c[1], c[2])
            next if n0 == n1 || !n1 || board.connected?(n0, n1)
            puts "#{n0.x} #{n0.y} #{n0.z} - #{n1.x} #{n1.y} #{n1.z}"
            board.addEdge(n0, n1)
          end
        end
      end
    end
  end

  board.normalize()
  board.write()
  board
end
