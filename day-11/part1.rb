Rule = Data.define(:applicable, :op)

def transmogrifyer(stones, times)
  rules = [
    Rule.new(
      applicable: ->(stone) { stone == 0 },
      op: ->(stone) { 1 }
    ),
    Rule.new(
      applicable: ->(stone) do
        stone.to_s.length % 2 == 0
      end,
      op: ->(stone) do
        [
          stone.to_s[...(stone.to_s.length / 2)].to_i,
          stone.to_s[(stone.to_s.length / 2)...].to_i
        ]
      end
    ),
    Rule.new(
      applicable: ->(stone) { true },
      op: ->(stone) { stone * 2024 }
    )
  ]
  cache = {}
  times.times do |n|
    print "." if n % 10 == 0
    stones = stones.flat_map do |stone|
      cache[stone] ||= rules.detect { |rule| rule.applicable[stone] }.op[stone]
    end
  end
  stones
end

# input = "125 17"
input = File.read(ARGV[0])

stones = input.split(" ").map(&:to_i)
result = transmogrifyer(stones, 75)
puts result.size
