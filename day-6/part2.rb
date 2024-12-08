require_relative "support"

map = parse_map(File.read(ARGV[0]).split("\n"))

# get guards postion
guard = map.guard

visited_obstacles = Set.new

# have the guard walk around the map
# when it hits an obstacle, keep track of that obstacle in a list
# on each step, check to see what would happen if the guard turns - if they would hit an already visited obstacle, make a note of the potential new obstacle position, then continue on

while map.on_map?(guard.position)
  # if the guard were to turn now, would they hit a known obstacle?
  if nearest_obstacle(guard.rotate, visited_obstacles)
    map.add_potential_obstacle(Obstacle.new(position: guard.next_step))
  end

  # take the next step
  next_step = guard.next_step
  obstacle = map.obstacles.find { |o| o.position == next_step }
  if obstacle
    visited_obstacles << obstacle
    guard = guard.rotate
  else
    guard = guard.take_step
  end
end

puts "Visited obstacles: #{visited_obstacles.size}"
puts "Potential obstacles: #{map.potential_obstacles.size}"
puts map
