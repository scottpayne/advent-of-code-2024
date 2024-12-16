def parse(lines)
  map_lines, move_lines = lines.slice_before { |line| line =~ /^\s*$/ }.to_a
  map = parse_map(map_lines)
  moves = parse_moves(move_lines.join(""))
  {map:, moves:}
end

Position = Data.define(:x, :y) do
  def +(other)
    Position.new(x: x + other.x, y: y + other.y)
  end

  def -(other)
    Position.new(x: x - other.x, y: y - other.y)
  end
end

MapTile = Data.define(:moveable, :glyph)
WALL = MapTile.new(moveable: false, glyph: "#")
ROBOT = MapTile.new(moveable: true, glyph: "@")
BARREL = MapTile.new(moveable: true, glyph: "O")
SPACE = MapTile.new(moveable: false, glyph: ".")

def position_enumerator(start_position:, end_position:)
  if start_position.x == end_position.x
    step = (start_position.y < end_position.y) ? 1 : -1
    Enumerator.new do |yielder|
      (start_position.y..end_position.y).step(step).each.map do |y|
        yielder.yield Position.new(x: start_position.x, y:)
      end
    end
  elsif start_position.y == end_position.y
    step = (start_position.x < end_position.x) ? 1 : -1
    Enumerator.new do |yielder|
      (start_position.x..end_position.x).step(step).each.map do |x|
        yielder.yield Position.new(x:, y: start_position.y)
      end
    end
  else
    raise ArgumentError, "start_position and end_position must be on the same row or column"
  end
end

Move = Data.define(:glyph, :position_offset)
UP = Move.new(glyph: "^", position_offset: Position.new(x: 0, y: -1))
DOWN = Move.new(glyph: "v", position_offset: Position.new(x: 0, y: 1))
LEFT = Move.new(glyph: "<", position_offset: Position.new(x: -1, y: 0))
RIGHT = Move.new(glyph: ">", position_offset: Position.new(x: 1, y: 0))

def parse_map_line(line)
  line.chars.each.lazy.map do |char|
    case char
    when "#"
      WALL
    when "."
      SPACE
    when "O"
      BARREL
    when "@"
      ROBOT
    end
  end
end

def parse_map(map_lines)
  map_lines.each.with_index.with_object({}) do |(line, y), map|
    parse_map_line(line).each.with_index do |object, x|
      map[Position.new(x:, y:)] = object
    end.force
  end
end

def parse_moves(moves_line)
  moves_line.chars.map do |char|
    case char
    when "^"
      UP
    when "v"
      DOWN
    when ">"
      RIGHT
    when "<"
      LEFT
    end
  end
end

def find_next_space(map:, starting_position:, move:)
  position = starting_position
  while map[position] != SPACE && map[position] != WALL && !map[position].nil?
    position += move.position_offset
  end
  if map[position] == SPACE
    position
  end
end

def process_move(map:, position:, move:)
  space_position = find_next_space(map:, starting_position: position, move:)
  new_position = position
  if space_position
    position_enumerator(start_position: space_position, end_position: position).each do |pos|
      map[pos] = map[pos - move.position_offset]
    end
    map[position] = SPACE
    new_position += move.position_offset
  end
  new_position
end

def process_moves(map:, moves:)
  robot_position = map.find { |position, object| object == ROBOT }.first
  # puts "Starting map:"
  # print_map(map:)
  # puts
  moves.each.with_index do |move, idx|
    # File.open("output/map-#{"%03d" % idx}", "w") do |f|
    robot_position = process_move(map:, position: robot_position, move:)
    # f.puts "Move #{move.glyph}"
    # print_map(map:, handle: f)
    # end
  end
end

def calculate_gps_sum(map:)
  map.select { |position, object| object == BARREL }.map { |position, _| position.x + position.y * 100 }.sum
end

def print_map(map:, handle: $stdout)
  y = 0
  map.each do |position, object|
    if position.y > y
      y = position.y
      handle.puts
    end
    handle.print object.glyph
  end
end

def main
  input_text = File.readlines(ARGV[0]).map(&:chomp)
  parsed = parse(input_text)
  map = parsed[:map]
  moves = parsed[:moves]
  process_moves(map:, moves:)
  # print_map(map:)
  calculate_gps_sum(map:)
end
puts main
