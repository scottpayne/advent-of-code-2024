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
    [[row + 1, column], [row - 1, column], [row, column + 1], [row, column - 1]].each.with_object([]) do |(r, c), acc|
      next if r < 0 || c < 0 || r >= @map.size || c >= @map[0].size
      acc << [r, c, self[r, c]] unless self[r, c].nil?
    end
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

def find_perimiter(garden_map, region)
  region_key = region.first.last
  region.sum do |row, col, _|
    4 - garden_map.neighbours(row, col).count { |_, _, neighbour_key| neighbour_key == region_key }
  end
end

def main
  input_text = File.read(ARGV[0])
  garden_map = GardenMap.parse(input_text)
  puts calc(garden_map)
end
main
