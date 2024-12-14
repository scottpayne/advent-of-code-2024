Position = Data.define(:row, :column)

class GardenMap
  include Enumerable

  def initialize(map = [[]])
    @map = map
  end

  def self.parse(input_text)
    new.parse(input_text)
  end

  def [](row, column)
    return nil if out_of_bounds?(row, column)
    @map.dig(row, column)
  end

  def each
    @map.each.with_index { |row, row_idx| row.each.with_index { |column, column_idx| yield [row_idx, column_idx, self[row_idx, column_idx]] } }
  end

  def parse(input_text)
    @map = input_text.split("\n").map do |row|
      row.chars
    end
    self
  end

  def neighbours(row, column)
    [[row - 1, column], [row, column + 1], [row + 1, column], [row, column - 1]].each.with_object([]) do |(r, c), acc|
      acc << [r, c, self[r, c]] unless self[r, c].nil?
    end
  end

  private

  def out_of_bounds?(row, column)
    row < 0 || column < 0 || row >= @map.size || column >= @map[0].size
  end
end

def calc(garden_map)
  visited = []
  garden_map.sum do |plot|
    next 0 if visited.include?(plot)
    region = find_region(garden_map, plot, [])
    visited += region
    perimiter = find_perimiter(garden_map, region)
    perimiter * region.size
  end
end

def find_region(garden_map, plot, visited)
  row, column, key = plot
  return [] if visited.include?(plot)
  visited << plot

  neighbours = garden_map.neighbours(row, column).select { |_, _, neighbour_key| neighbour_key == key }
  [plot] + neighbours.flat_map do |row, col, neighbour_key|
    find_region(garden_map, [row, col, neighbour_key], visited)
  end
end

class SidesVisitor
  SIDES = [
    TOP = :top,
    RIGHT = :right,
    BOTTOM = :bottom,
    LEFT = :left
  ].freeze
  def initialize(garden_map, region)
    @garden_map = garden_map
    @region = region
    @visited = []
  end

  def visit
    @visited = []
    region.each do |plot|
      sides(plot)
    end
  end

  private

  def sides(plot)
    [[-1, 0, TOP], [0, 1, RIGHT], [1, 0, BOTTOM], [0, -1, LEFT]].each.with_object([]) do |(row_offset, col_offset, side), sides|
      neighbour_coords = [plot[0] + row_offset, plot[1] + col_offset]
      neighbour = garden_map[*neighbour_coords]
      if neighbour.nil?
        sides.push(side)
      end
    end
  end

  attr_reader :garden_map, :region
  attr_accessor :visited
end

def main
  input_text = File.read(ARGV[0])
  garden_map = GardenMap.parse(input_text)
  puts calc(garden_map)
end
main
