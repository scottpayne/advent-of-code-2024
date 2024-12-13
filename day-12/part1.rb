Position = Data.define(:row, :column)

def parse(input_text)
  input_text.split("\n").each.with_index.with_object({}) do |(row, row_no), map|
    row.chars.each.with_index do |char, column_no|
      map[Position.new(row: row_no, column: column_no)] = char
    end
  end
end

def neighbours(position, map)
  [
    Position.new(row: position.row + 1, column: position.column),
    Position.new(row: position.row - 1, column: position.column),
    Position.new(row: position.row, column: position.column + 1),
    Position.new(row: position.row, column: position.column - 1)
  ].map { |neighbour| map[neighbour] == map[position] }.compact
end

def fencing_cost(position, region, map)
  perimiter = 4 - neighbours(position).count { |n| map[n] == region }
  area = 1
  perimiter + area
end

def solve(map)
  map.sum do |position, region|
    fencing_cost(position, region, map)
  end
end

def main
  input = File.read(ARGV[0])
  map = parse(input)
  puts solve(map)
end
main
