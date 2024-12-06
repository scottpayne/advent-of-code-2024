Coordinate = Data.define(:row, :column) do
  def -(other)
    Coordinate.new(row: row - other.row, column: column - other.column)
  end

  def +(other)
    Coordinate.new(row: row + other.row, column: column + other.column)
  end
end
Letter = Data.define(:letter, :coordinate)

input = <<~EOI
  MMMSXXMASM
  MSAMXMSMSA
  AMXSXMAAMM
  MSAMASMSMX
  XMASAMXAMM
  XXAMMXXAMA
  SMSMSASXSS
  SAXAMASAAA
  MAMMMXMMMM
  MXMXAXMASX
EOI

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

xs = letters.values.select { |letter| letter.letter == "X" }

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

def xmas_count(letter_x, letters)
  m = valid_neighbours("M", neighbours(letter_x, letters))
  possible_directions = m.map { |letter| letter.coordinate - letter_x.coordinate }

  m.zip(possible_directions).map do |m, direction|
    next 0 if letters[m.coordinate + direction].nil?
    next 0 if letters[m.coordinate + direction + direction].nil?
    if letters[m.coordinate + direction].letter == "A" && letters[m.coordinate + direction + direction].letter == "S"
      1
    else
      0
    end
  end.sum
end

def total_xmas_count(letters)
  xs = letters.values.select { |letter| letter.letter == "X" }
  xs.map do |letter_x|
    xmas_count(letter_x, letters)
  end.sum
end

puts total_xmas_count(letters)
