
pattern = %r{mul\((?<a>\d+),(?<b>\d+)\)}

filename = ARGV[0]
input = File.read(filename)

puts input.scan(pattern).map { |a, b| a.to_i * b.to_i }.sum