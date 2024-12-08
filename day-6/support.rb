Position = Data.define(:row, :column) do
  def +(other)
    Position.new(row: row + other.row, column: column + other.column)
  end
end

Guard = Data.define(:direction, :position)
Obstacle = Data.define(:position)

class Map
  def initialize(rows: 0, columns: 0)
    @rows = rows
    @columns = columns
    @obstacles = []
    @obstacles_by_column = {}
    @obstacles_by_row = {}
    @guard = nil
    @visited_positions = Set.new
  end

  attr_accessor :guard, :obstacles
  attr_reader :rows, :columns

  def add_obstacle(obstacle)
    @obstacles << obstacle
    @obstacles_by_column[obstacle.position.column] ||= []
    @obstacles_by_column[obstacle.position.column] << obstacle
    @obstacles_by_row[obstacle.position.row] ||= []
    @obstacles_by_row[obstacle.position.row] << obstacle
  end

  def obstacles_by_column(column)
    @obstacles_by_column[column]
  end

  def obstacles_by_row(row)
    @obstacles_by_row[row]
  end

  def mark_visited(position)
    @visited_positions << position
  end

  def visited_count
    @visited_positions.count
  end

  def on_map?(position)
    position.row >= 0 && position.row < rows && position.column >= 0 && position.column < columns
  end

  def to_s
    (0...rows).map do |row|
      (0...columns).map do |column|
        position = Position.new(row: row, column: column)
        if @visited_positions.include?(position)
          "X"
        elsif @obstacles.any? { |o| o.position == position }
          "#"
        else
          "."
        end
      end.join("")
    end.join("\n")
  end
end

Direction = Data.define(:glyph, :next_direction_glyph, :position_finder, :obstacle_offset, :walk_offset) do
  def next_direction
    Directions::ALL.find { |d| d.glyph == next_direction_glyph }
  end
end

module Directions
  ALL = [
    UP = Direction.new(
      glyph: "^",
      next_direction_glyph: ">",
      position_finder: ->(starting_position, positions) do
        positions.select { |p| p in Position(^(...starting_position.row), ^(starting_position.column)) }
      end,
      obstacle_offset: Position.new(row: 1, column: 0),
      walk_offset: Position.new(row: -1, column: 0)
    ),
    RIGHT = Direction.new(
      glyph: ">",
      next_direction_glyph: "v",
      position_finder: ->(starting_position, positions) do
        positions.select { |p| p in Position(^(starting_position.row), ^((starting_position.column + 1)..)) }
      end,
      obstacle_offset: Position.new(row: 0, column: -1),
      walk_offset: Position.new(row: 0, column: 1)
    ),
    DOWN = Direction.new(
      glyph: "v",
      next_direction_glyph: "<",
      position_finder: ->(starting_position, positions) do
        positions.select { |p| p in Position(^((starting_position.row + 1)..), ^(starting_position.column)) }
      end,
      obstacle_offset: Position.new(row: -1, column: 0),
      walk_offset: Position.new(row: 1, column: 0)
    ),
    LEFT = Direction.new(
      glyph: "<",
      next_direction_glyph: "^",
      position_finder: ->(starting_position, positions) do
        positions.select { |p| p in Position(^(starting_position.row), ^(...starting_position.column)) }
      end,
      obstacle_offset: Position.new(row: 0, column: 1),
      walk_offset: Position.new(row: 0, column: -1)
    )
  ]
end

# input is an array of strings
def parse_map(input)
  map = Map.new(rows: input.size, columns: input.first.size)
  input.each.with_index do |line, line_no|
    line.chars.each.with_index do |char, column_no|
      if char == "#"
        map.add_obstacle(Obstacle.new(position: Position.new(row: line_no, column: column_no)))
      elsif Directions::ALL.map(&:glyph).include?(char)
        map.guard = Guard.new(
          direction: Directions::ALL.find { |d| d.glyph == char },
          position: Position.new(row: line_no, column: column_no)
        )
      end
    end
  end
  map
end

def manhattan_distance(position_a, position_b)
  (position_a.row - position_b.row).abs + (position_a.column - position_b.column).abs
end

def nearest_position(direction, position, positions)
  direction.position_finder.call(position, positions).min_by { |p| manhattan_distance(p, position) }
end
