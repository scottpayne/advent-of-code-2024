require_relative "lib/parser"
require_relative "lib/part2/map_printer"
require_relative "lib/values"
require_relative "lib/part2/process_move"

def process_moves(map:, moves:)
  moves.each.with_index do |move, idx|
    robot_position = map.find { |position, object| object == ROBOT }.first
    map = process_move(map:, position: robot_position, move:)
    # puts "Move #{move.glyph}"
    # puts Part2::MapPrinter.new(map).print
    # puts
  end
  map
end

def calculate_gps_sum(map:)
  map.select { |_, object| object == BARREL_LEFT }.keys.map { |position| position.x + position.y * 100 }.sum
end

def main
  input_text = File.readlines(ARGV[0]).map(&:chomp)
  parsed = Parser.new(input_text).parse
  # Part2::MapPrinter.new(parsed.map).print
  map = parsed.map
  moves = parsed.moves
  final_map = process_moves(map:, moves:)
  calculate_gps_sum(map: final_map)
end
puts main
