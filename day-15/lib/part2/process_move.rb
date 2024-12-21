require "dry-monads"

def process_move(map:, position:, move:)
  Part2::Mover.move(map:, move:, position:)
end

module Part2
  class Mover
    include Dry::Monads[:result]

    def self.move(map:, position:, move:)
      new(move:).moves(map:, position:)
    end

    def initialize(move:)
      @move = move
    end

    def moves(position:, map:)
      make_moves(position:, map:).value_or(map)
    end

    private

    def make_moves(position:, map:)
      object = map[position]
      if object == SPACE
        Success(map)
      elsif object.nil? || object == WALL
        Failure(position)
      elsif look_sideways?(object)
        make_moves(position: position + move.position_offset, map: map).bind do |left|
          make_moves(position: position + sideways_offset(object), map: swap(position:, map: left))
        end
      else
        make_moves(position: position + move.position_offset, map:).fmap do |left|
          swap(position:, map: left)
        end
      end
    end

    attr_accessor :map, :move

    def look_sideways?(object)
      [UP, DOWN].include?(move) && [BARREL_LEFT, BARREL_RIGHT].include?(object)
    end

    def sideways_offset(object)
      {
        BARREL_LEFT => RIGHT.position_offset,
        BARREL_RIGHT => LEFT.position_offset
      }.fetch(object)
    end

    def swap(position:, map:)
      next_position = position + move.position_offset
      return map if map[next_position].nil?

      map.merge(
        position => map[next_position],
        next_position => map[position]
      )
    end
  end
end
