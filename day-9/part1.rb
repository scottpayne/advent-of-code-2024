DiskMap = Data.define(:blocks)

BlockRun = Data.define(:count, :contents)
FileBlocks = Data.define(:id)
FreeSpace = Data.define

def enumerate_blocks(input_line)
  Enumerator.new do |yielder|
    input_line.chars.each_slice(2).with_index do |pair, index|
      pair[0].to_i.times { yielder.yield FileBlocks.new(id: index) }
      pair[1].to_i.times { yielder.yield FreeSpace.new }
    end
  end
end

def checksum(blocks)
  blocks.map.with_index do |block, idx|
    case block
    in FileBlocks(id: id)
      id * idx
    in FreeSpace
      0
    end
  end.sum
end

input = File.read(ARGV[0]).chomp("\n")
require "../tap_assert"

assert 0 * 0 + 0 * 1 + 0 * 2 + 0 * 3 + 1 * 4 + 1 * 5, checksum(enumerate_blocks("222"))
assert 0 * 0 + 0 * 1 + 1 * 2 + 1 * 3, checksum(enumerate_blocks("202"))
