require "rspec"
require_relative "part1"

RSpec.describe "Part 1 functions" do
  describe "process_move" do
    it "doesn't process a move when there's a wall" do
      map = {
        Position.new(x: 0, y: 0) => BARREL,
        Position.new(x: 0, y: 1) => WALL
      }
      expect { process_move(map: map, position: Position.new(x: 0, y: 0), move: DOWN) }.not_to change { map }
    end

    it "doesn't process a move if that would go off the map" do
      map = {Position.new(x: 0, y: 0) => BARREL}
      expect { process_move(map: map, position: Position.new(x: 0, y: 0), move: UP) }.not_to change { map }
    end

    it "processes a move if the object is movable and can move on the map" do
      map = {
        Position.new(x: 0, y: 0) => BARREL,
        Position.new(x: 1, y: 0) => SPACE
      }
      process_move(map:, position: Position.new(x: 0, y: 0), move: RIGHT)
      expect(map).to eq({
        Position.new(x: 0, y: 0) => SPACE,
        Position.new(x: 1, y: 0) => BARREL
      })
    end

    it "moves multiple movable items at once" do
      map = {
        Position.new(x: 0, y: 0) => BARREL,
        Position.new(x: 1, y: 0) => BARREL,
        Position.new(x: 2, y: 0) => SPACE
      }
      process_move(map:, position: Position.new(x: 0, y: 0), move: RIGHT)
      expect(map).to eq({
        Position.new(x: 0, y: 0) => SPACE,
        Position.new(x: 1, y: 0) => BARREL,
        Position.new(x: 2, y: 0) => BARREL
      })
    end

    it "doesn't move anything if it hits a wall" do
      map = {
        Position.new(x: 1, y: 0) => BARREL,
        Position.new(x: 2, y: 0) => BARREL,
        Position.new(x: 3, y: 0) => WALL
      }
      expect { process_move(map:, position: Position.new(x: 1, y: 0), move: RIGHT) }.not_to change { map }
    end

    it "moves the robot into empty space" do
      map = {
        Position.new(x: 0, y: 0) => ROBOT,
        Position.new(x: 1, y: 0) => SPACE
      }
      process_move(map:, position: Position.new(x: 0, y: 0), move: RIGHT)
      expect(map).to eq({
        Position.new(x: 0, y: 0) => SPACE,
        Position.new(x: 1, y: 0) => ROBOT
      })
    end

    it "allows the robot to push barrels into empty space" do
      map = {
        Position.new(x: 0, y: 0) => ROBOT,
        Position.new(x: 1, y: 0) => BARREL,
        Position.new(x: 2, y: 0) => SPACE
      }
      process_move(map:, position: Position.new(x: 0, y: 0), move: RIGHT)
      expect(map).to eq({
        Position.new(x: 0, y: 0) => SPACE,
        Position.new(x: 1, y: 0) => ROBOT,
        Position.new(x: 2, y: 0) => BARREL
      })
    end

    it "doesn't allow the robot to swap places with barrels" do
      map = {
        Position.new(x: 0, y: 0) => ROBOT,
        Position.new(x: 1, y: 0) => BARREL
      }
      expect { process_move(map:, position: Position.new(x: 0, y: 0), move: RIGHT) }.not_to change { map }
    end
  end
end
