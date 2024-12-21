require "rspec"
require "immutable/hash"

require_relative "../../lib/values"
require_relative "../../lib/part2/process_move"
require_relative "../../lib/part2/map_printer"

RSpec.describe "process_move" do
  def do_the_move(map_text:, move:)
    parsed_map = parse_map(map_text)
    map_to_string(
      process_move(map: parsed_map, position: robot_position(parsed_map), move:)
    )
  end

  def parse_map(text)
    character_map = CharacterMap.new
    Immutable::Hash.new(
      text.lines.each.with_index.with_object({}) do |(line, y), acc|
        line.chomp.chars.each.with_index { |char, x| acc[Position.new(x:, y:)] = character_map.parse(char) }
      end
    )
  end

  def robot_position(parsed_map)
    parsed_map.find { |position, object| object == ROBOT }.first
  end

  def map_to_string(map)
    Part2::MapPrinter.new(map).print
  end

  it "pushes the barrel right when the robot is on the left" do
    map_text = "@[].#"
    new_map = do_the_move(map_text:, move: RIGHT)
    expect(new_map.chomp).to eq(".@[]#")
  end

  it "pushes the barrel left when the robot is on the right" do
    map_text = "#.[]@"
    new_map = do_the_move(map_text:, move: LEFT)
    expect(new_map.chomp).to eq("#[]@.")
  end

  it "pushes a barrel down into an empty space when the robot is on the left" do
    map_text = <<~EOM
      @.
      []
      ..
    EOM
    new_map = do_the_move(map_text:, move: DOWN)
    expect(new_map).to eq(<<~EOM)
      ..
      @.
      []
    EOM
  end

  it "pushes a barrel down into an empty space when the robot is on the right" do
    map_text = <<~EOM
      .@
      []
      ..
    EOM
    new_map = do_the_move(map_text:, move: DOWN)
    expect(new_map).to eq(<<~EOM)
      ..
      .@
      []
    EOM
  end

  it "pushes overlapping barrels into space" do
    map_text = <<~EOM
      ..@.
      .[].
      [][]
      ....
    EOM
    new_map = do_the_move(map_text:, move: DOWN)
    expect(new_map).to eq(<<~EOM)
      ....
      ..@.
      .[].
      [][]
    EOM
  end

  it "won't push overlapping barrels into a wall" do
    map_text = <<~EOM
      ..@.
      .[].
      [][]
      #...
    EOM
    new_map = do_the_move(map_text:, move: DOWN)
    expect(new_map).to eq(map_text)
  end

  it "pushes a barrel into space even when a wall is nearby" do
    map_text = <<~EOM
      ..@.
      .[].
      #...
    EOM
    new_map = do_the_move(map_text:, move: DOWN)
    expect(new_map).to eq(<<~EOM)
      ....
      ..@.
      #[].
    EOM
  end

  it "moves the robot away from things without messing them up" do
    map_text = <<~EOM
      .@[]
    EOM
    new_map = do_the_move(map_text:, move: LEFT)
    expect(new_map).to eq(<<~EOM)
      @.[]
    EOM
  end
end
