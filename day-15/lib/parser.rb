require "immutable/hash"
require "immutable/list"

require_relative "values"

class Parser
  Result = Data.define(:map, :moves)

  def initialize(input)
    @input = input
  end

  def parse
    map_lines, move_lines = input.slice_before { |line| line =~ /^\s*$/ }.to_a
    map = parse_map(map_lines)
    moves = parse_moves(move_lines.join(""))
    Result.new(map:, moves:)
  end

  private

  def parse_map_line(line)
    line
      .chars
      .each
      .lazy
      .map { |char| character_map.parse(char) }
      .flat_map { |object| double_wide(object) }
  end

  def double_wide(object)
    case object
    in BARREL then [BARREL_LEFT, BARREL_RIGHT]
    in ROBOT then [ROBOT, SPACE]
    else
      [object, object]
    end
  end

  def parse_map(map_lines)
    Immutable::Hash.new(
      map_lines.each.with_index.with_object({}) do |(line, y), map|
        parse_map_line(line).each.with_index do |object, x|
          map[Position.new(x:, y:)] = object
        end.force
      end
    )
  end

  def parse_moves(moves_line)
    Immutable::List.from_enum(
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
    )
  end

  def character_map
    @character_map ||= CharacterMap.new
  end

  attr_reader :input
end
