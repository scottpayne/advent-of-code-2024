Coordinate = Data.define(:row, :column) do
  def -(other)
    Coordinate.new(row: row - other.row, column: column - other.column)
  end

  def +(other)
    Coordinate.new(row: row + other.row, column: column + other.column)
  end
end
Letter = Data.define(:letter, :coordinate)

# input = <<~EOI
#   MMMSXXMASM
#   MSAMXMSMSA
#   AMXSXMAAMM
#   MSAMASMSMX
#   XMASAMXAMM
#   XXAMMXXAMA
#   SMSMSASXSS
#   SAXAMASAAA
#   MAMMMXMMMM
#   MXMXAXMASX
# EOI

input = File.read("input.txt")

input_matrix = input.split("\n").map { |line| line.split("") }

letters = input_matrix.each.with_index.with_object({}) do |(row, row_index), acc|
  row.each_with_index do |col, col_index|
    coord = Coordinate.new(row_index, col_index)
    acc[coord] =
      Letter.new(
        letter: input_matrix[row_index][col_index],
        coordinate: coord
      )
  end
end

def neighbour_locations(letter)
  row = letter.coordinate.row
  column = letter.coordinate.column
  ((row - 1)..(row + 1)).flat_map do |neighbour_row|
    ((column - 1)..(column + 1)).map do |neighbour_column|
      coord = Coordinate.new(row: neighbour_row, column: neighbour_column)
      (coord == letter.coordinate) ? nil : coord
    end
  end
end

def neighbours(letter, letters)
  neighbour_locations(letter).map do |coord|
    letters[coord]
  end.compact
end

def valid_neighbours(expected_letter, neighbours)
  neighbours.select do |neighbour|
    neighbour.letter == expected_letter
  end
end

def centre_of_x_mas(letter_a, letters)
  candidates = neighbours(letter_a, letters)
  return false if candidates.length < 8
  ms = candidates.select { |letter| letter.letter == "M" && is_diagonal?(letter_a.coordinate, letter.coordinate) }
  return false if ms.length < 2
  ss = candidates.select { |letter| letter.letter == "S" }
  ms.product(ss).count do |(m, s)|
    letter_a.coordinate - m.coordinate == s.coordinate - letter_a.coordinate
  end == 2
end

def is_diagonal?(coordinate_a, coordinate_b)
  return false if coordinate_a.nil? || coordinate_b.nil?
  diagonals = [[1, 1], [1, -1], [-1, 1], [-1, -1]].map { |row, column| Coordinate.new(row:, column:) }
  direction = coordinate_a - coordinate_b
  diagonals.include?(direction)
end

def total_x_mas_count(letters)
  as = letters.values.select { |letter| letter.letter == "A" }
  as.count { |a| centre_of_x_mas(a, letters) }
end


puts total_x_mas_count(letters)
