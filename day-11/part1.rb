require "memo_wise"

Rule = Data.define(:applicable, :op)

class Transmogrifyer
  prepend MemoWise

  def transmogrify(stones, blinks)
    stones.sum { |stone| transmogrify_one(stone, blinks) }
  end

  private

  def transmogrify_one(stone, blinks)
    return 1 if blinks <= 0
    new_stones = RULES.detect { |rule| rule.applicable[stone] }.op[stone]
    Array(new_stones).sum { |new_stone| transmogrify_one(new_stone, blinks - 1) }
  end
  memo_wise :transmogrify_one

  RULES =
    [
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
end

# input = "125 17"
input = File.read(ARGV[0])

stones = input.split(" ").map(&:to_i)
result = Transmogrifyer.new.transmogrify(stones, 75)
puts result
