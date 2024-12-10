DiskMap = Data.define(:blocks)

BlockRun = Data.define(:count, :contents) do
  def empty?
    count.zero?
  end
end
FileBlocks = Data.define(:id) do
  def <=>(other)
    id <=> other.id
  end
end
FreeSpace = Data.define

def enumerate_blocks(input_line)
  Enumerator.new do |yielder|
    input_line.chars.each_slice(2).with_index do |pair, index|
      pair[0].to_i.times { yielder.yield FileBlocks.new(id: index) }
      pair[1].to_i.times { yielder.yield FreeSpace.new }
    end
  end
end

def parse(input_line)
  input_line.chars.each_slice(2).flat_map.with_index do |(file_space, free_space), index|
    [
      BlockRun.new(count: file_space.to_i, contents: FileBlocks[index]),
      BlockRun.new(count: free_space.to_i, contents: FreeSpace.new)
    ].reject(&:empty?)
  end
end

class FileSizeMap
  def initialize(blocks)
    @map =
      blocks
        .select { |block| block in FileBlocks }
        .tally
        .group_by { |_, v| v }
        .transform_values { |vs| vs.map(&:first).sort.reverse }
    @deleted = []
  end

  def file_sizes
    @map.keys.sort.reverse
  end

  def delete_by_size(size)
    (@map[size] || []).shift.tap do |deleted|
      @map.delete(size) if @map.key?(size) && @map[size].empty?
      @deleted << deleted unless deleted.nil?
    end
  end

  def delete(block)
    @map.each do |k, v|
      v.delete(block)
      @map.delete(k) if @map[k].empty?
    end
  end

  def deleted?(file_block)
    @deleted.include?(file_block)
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

def replace_free_space(count, file_size_map, yielder)
  available_sizes = file_size_map.file_sizes.reject { |size| size > count }
  if available_sizes.empty?
    count.times { yielder.yield FreeSpace.new }
    return
  end

  next_size = available_sizes.first
  file_block = file_size_map.delete_by_size(next_size)
  next_size.times { yielder.yield file_block }

  replace_free_space(count - next_size, file_size_map, yielder)
end

def defrag(blocks)
  file_size_map = FileSizeMap.new(blocks)
  Enumerator.new do |yielder|
    free_count = 0
    blocks.each do |block|
      if block.is_a?(FileBlocks)
        replace_free_space(free_count, file_size_map, yielder)
        free_count = 0
        if file_size_map.deleted?(block)
          yielder.yield FreeSpace.new
        else
          file_size_map.delete(block)
          yielder.yield block
        end
      else
        free_count += 1
      end
    end
  end
end

# puts checksum(defrag(enumerate_blocks(input)))

def do_tests
  require "awesome_print"
  require "../tap_assert"

  blocks = enumerate_blocks("2342202")
  # ap blocks.to_a
  ap defrag(blocks).to_a

  # assert({2 => [FileBlocks[2], FileBlocks[0]], 3 => [FileBlocks[1]]}, file_id_size_map(parse("20302")))
  # assert({2 => [FileBlocks[2], FileBlocks[0]], 3 => [FileBlocks[1]]}, file_id_size_map(parse("21312")))
end

def main
  input = File.read(ARGV[0]).chomp("\n")
  puts defrag(enumerate_blocks(input)).to_a
end

main
