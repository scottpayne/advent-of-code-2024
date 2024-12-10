Position = Data.define(:row, :column)

def parse(input)
  input.split("\n").each.with_index.with_object({}) do |(row, row_no), map|
    row.chars.each.with_index do |char, column_no|
      map[Position.new(row: row_no, column: column_no)] = char.to_i
    end
  end
end

def starting_points(map)
  map.select { |position, height| height == 0 }.keys
end

def neighbours(position)
  [
    Position.new(row: position.row + 1, column: position.column),
    Position.new(row: position.row - 1, column: position.column),
    Position.new(row: position.row, column: position.column + 1),
    Position.new(row: position.row, column: position.column - 1)
  ]
end

HIGHEST_HIGHT = 9

def highest_points(map, starting_point)
  height = map[starting_point].to_i
  return starting_point if height == HIGHEST_HIGHT
  neighbours(starting_point)
    .select { |neighbour| map[neighbour].to_i == height + 1 }
    .map { |neighbour| highest_points(map, neighbour) }
end

def main
  require "awesome_print"
  input = File.read(ARGV[0])
  map = parse(input)
  total = starting_points(map).sum do |trailhead|
    highest_points(map, trailhead).flatten.uniq.size
  end
  puts total
end
main
