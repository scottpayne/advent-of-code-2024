require "sorted_set"

Position = Data.define(:row, :column) do
  def -(other)
    Position.new(row: row - other.row, column: column - other.column)
  end

  def +(other)
    Position.new(row: row + other.row, column: column + other.column)
  end

  def <=>(other)
    [row, column] <=> [other.row, other.column]
  end

  def to_s
    "(#{row}, #{column})"
  end
end

class AntennaMap
  def initialize
    @antennas = {}
    @bottom_corner = Position[0, 0]
  end

  attr_reader :antennas

  def parse_input(input_lines)
    build_antenna_map(input_lines)
    @bottom_corner = find_bottom_corner(input_lines)
  end

  def in_bounds?(position)
    position in Position(^(1..bottom_corner.row), ^(1..bottom_corner.column))
  end

  def to_s
    positions_of_antennae = antennae_by_position
    (0...bottom_corner.row).map do |row|
      (0...bottom_corner.column).map do |column|
        position = Position.new(row: row, column: column)
        positions_of_antennae[position] || "."
      end.join
    end.join("\n")
  end

  attr_reader :bottom_corner

  private

  def build_antenna_map(input_lines)
    input_lines.reject(&:empty?).map.with_index(1) do |row, row_no|
      row.chomp("\n").chars.map.with_index(1) do |char, column_no|
        next unless char in "a".."z" | "A".."Z" | "0".."9"
        antennas[char] ||= SortedSet.new
        antennas[char] << Position.new(row: row_no, column: column_no)
      end
    end
  end

  def find_bottom_corner(input_lines)
    Position.new(
      row: input_lines.count { |line| !line.empty? },
      column: input_lines.first.chomp("\n").size
    )
  end

  def antennae_by_position
    {}.tap do |result|
      antennas.each do |antenna, positions|
        positions.each do |position|
          result[position] = antenna
        end
      end
    end
  end
end

def enumerated_antinodes(p1, p2, map)
  offset = p1 - p2
  increasing = Enumerator.produce(p1) { |pos| pos + offset }
  decreasing = Enumerator.produce(p2) { |pos| pos - offset }
  increasing.take_while { |p| map.in_bounds?(p) }.to_a +
    decreasing.take_while { |p| map.in_bounds?(p) }.to_a
end

def all_antinodes(map)
  SortedSet.new(
    map.antennas.flat_map do |antenna, positions|
      positions.to_a.combination(2).flat_map { |p1, p2| enumerated_antinodes(p1, p2, map) }
    end
  )
end

input_lines = File.readlines(ARGV[0])
map = AntennaMap.new
map.parse_input(input_lines)

# ap map.antennas
antinodes = all_antinodes(map)
puts antinodes.count
