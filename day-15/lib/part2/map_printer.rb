require "stringio"

require_relative "../values"
require_relative "character_map"

module Part2
  class MapPrinter
    def initialize(map)
      @map = map
    end

    def print
      str = StringIO.new
      y = 0
      map.sort.each do |position, object|
        if position.y > y
          y = position.y
          str << "\n"
        end
        str << glyph(object)
      end
      str << "\n"
      str.string
    end

    private

    attr_reader :map

    def glyph(object)
      character_map.glyph(object)
    end

    def character_map
      @character_map ||= CharacterMap.new
    end
  end
end
