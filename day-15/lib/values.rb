Position = Data.define(:x, :y) do
  def +(other)
    Position.new(x: x + other.x, y: y + other.y)
  end

  def -(other)
    Position.new(x: x - other.x, y: y - other.y)
  end

  def <=>(other)
    [y, x] <=> [other.y, other.x]
  end

  def upto(other)
    if x == other.x
      step = (y < other.y) ? 1 : -1
      Enumerator.new do |yielder|
        (y..other.y).step(step).each.map do |step_y|
          yielder.yield Position.new(x:, y: step_y)
        end
      end
    elsif y == other.y
      step = (x < other.x) ? 1 : -1
      Enumerator.new do |yielder|
        (x..other.x).step(step).each.map do |step_x|
          yielder.yield Position.new(x: step_x, y:)
        end
      end
    else
      raise ArgumentError, "start_position and end_position must be on the same row or column"
    end
  end
end

MapTile = Data.define(:moveable, :glyph)
WALL = MapTile.new(moveable: false, glyph: "#")
ROBOT = MapTile.new(moveable: true, glyph: "@")
BARREL = MapTile.new(moveable: true, glyph: "O")
BARREL_LEFT = MapTile.new(moveable: true, glyph: "[")
BARREL_RIGHT = MapTile.new(moveable: true, glyph: "]")
SPACE = MapTile.new(moveable: false, glyph: ".")

Move = Data.define(:glyph, :position_offset)
UP = Move.new(glyph: "^", position_offset: Position.new(x: 0, y: -1))
DOWN = Move.new(glyph: "v", position_offset: Position.new(x: 0, y: 1))
LEFT = Move.new(glyph: "<", position_offset: Position.new(x: -1, y: 0))
RIGHT = Move.new(glyph: ">", position_offset: Position.new(x: 1, y: 0))
