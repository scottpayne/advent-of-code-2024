require_relative "../values"

class CharacterMap
  def parse(character)
    case character
    in "#" then WALL
    in "." then SPACE
    in "O" then BARREL
    in "[" then BARREL_LEFT
    in "]" then BARREL_RIGHT
    in "@" then ROBOT
    else
      raise "Unknown character: #{character}"
    end
  end

  def glyph(object)
    case object
    in WALL then "#"
    in SPACE then "."
    in BARREL then "O"
    in BARREL_LEFT then "["
    in BARREL_RIGHT then "]"
    in ROBOT then "@"
    else
      raise "Unknown object: #{object}"
    end
  end
end
