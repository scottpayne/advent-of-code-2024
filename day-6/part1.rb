require_relative "support"

# map = parse_map(test_input.split("\n"))
map = parse_map(File.read(ARGV[0]).split("\n"))

# get guards postion
guard = map.guard
# get the position of the nearest obstacle considering the guards direction

next_obstacle = nearest_position(guard.direction, guard.position, map.obstacles.map(&:position))

while next_obstacle
  # mark all the points between the guards old position and the new position inclusive as visited
  next_guard_position = next_obstacle + guard.direction.obstacle_offset
  # puts "Moving guard from #{guard.position} to #{next_guard_position}"
  map.mark_visited(guard.position)
  next_pos = guard.position + guard.direction.walk_offset
  while next_pos != next_guard_position
    # puts "Guard visiting #{next_pos}"
    map.mark_visited(next_pos)
    next_pos += guard.direction.walk_offset
  end

  # move guard to just before that obstacle, rotate the guard direction 90 degrees
  guard = map.guard = Guard.new(
    direction: guard.direction.next_direction,
    position: next_guard_position
  )
  next_obstacle = nearest_position(guard.direction, guard.position, map.obstacles.map(&:position))
end

# no more obstacles, guard can leave the map
guard_position = guard.position
while map.on_map?(guard_position)
  # puts "Guard is leaving the map at #{guard_position}"
  guard_position += guard.direction.walk_offset
  map.mark_visited(guard_position)
end

# puts map
puts "Visited count: #{map.visited_count}"
