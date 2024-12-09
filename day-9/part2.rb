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

def file_id_size_map(blocks)
  blocks.tally.each.with_object({}) do |(block, count), size_map|
    next unless block.is_a?(FileBlocks)
    size_map[count] ||= []
    size_map[count] << block
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

def defrag(blocks)
  file_blocks = blocks.lazy.select { |block| block.is_a?(FileBlocks) }
  file_blocks_from_end = file_blocks.reverse_each
  file_blocks_left = file_blocks.count

  Enumerator.new do |yielder|
    blocks.each do |block|
      if file_blocks_left == 0
        yielder.yield FreeSpace.new
      elsif block.is_a?(FileBlocks)
        yielder.yield block
        file_blocks_left -= 1
      else
        yielder.yield file_blocks_from_end.next
        file_blocks_left -= 1
      end
    end
  end
end

input = File.read(ARGV[0]).chomp("\n")

puts checksum(defrag(enumerate_blocks(input)))

def do_tests
  require "awesome_print"
  require "../tap_assert"
  checksum_test = ->(values) do
    values.map.with_index { |value, idx| value * idx }.sum
  end

  assert(checksum_test[[0, 0, 1, 1]], checksum(defrag(enumerate_blocks("202"))), "no free space")
  assert(checksum_test[[0, 0, 1, 1, 0, 0]], checksum(defrag(enumerate_blocks("222"))), "defragged, space matches file space")
  assert(checksum_test[[0, 0, 2, 1, 1, 2]], checksum(defrag(enumerate_blocks("21212"))))
  assert(checksum_test[[0, 0, 2, 2, 1, 1]], checksum(defrag(enumerate_blocks("23202"))), "defragged, more free space than file contents")
end
