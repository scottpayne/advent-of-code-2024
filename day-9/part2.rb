DiskMap = Data.define(:blocks)

BlockRun = Data.define(:count, :contents)
FreeSpace = Data.define


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

# puts checksum(defrag(enumerate_blocks(input)))

def do_tests
  require "awesome_print"
  require "../tap_assert"

  assert({2 => [FileBlocks[2], FileBlocks[0]], 3 => [FileBlocks[1]]}, file_id_size_map(enumerate_blocks("20302")))
  assert({2 => [FileBlocks[2], FileBlocks[0]], 3 => [FileBlocks[1]]}, file_id_size_map(enumerate_blocks("21312")))
end
