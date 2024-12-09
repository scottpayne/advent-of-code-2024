DiskMap = Data.define(:blocks)

FileBlocks = Data.define(:id, :block_count)
FreeSpace = Data.define(:block_count)

def parse(input_line)
  input_line.chars.each_slice(2).flat_map.with_index do |pair, index|
    [
      FileBlocks.new(id: index, block_count: pair[0]),
      FreeSpace.new(block_count: pair[1])
    ]
  end
end

input = File.read(ARGV[0]).chomp("\n")
require "awesome_print"
ap parse(input)
