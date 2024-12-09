DiskMap = Data.define(:blocks)

BlockRun = Data.define(:count, :contents)
FileBlocks = Data.define(:id)
FreeSpace = Data.define

def parse(input_line)
  input_line.chars.each_slice(2).flat_map.with_index do |pair, index|
    [
      BlockRun.new(count: pair[0].to_i, contents: FileBlocks.new(id: index)),
      BlockRun.new(count: pair[1].to_i, contents: FreeSpace.new)
    ].reject { |block_run| block_run in BlockRun(count: nil) }
  end
end

def checksum(blocks)
  blocks.map.with_object({idx: 0, sum: 0}) do |block_run, acc|
    start = acc[:idx]
    finish = start + block_run.count
    acc[:sum] +=
      case block_run.contents
      in FileBlocks(id: id)
        (start...finish).sum { |idx| idx * id }
      in FreeSpace
        0
      end
    acc[:idx] = finish
  end[:sum]
end

input = File.read(ARGV[0]).chomp("\n")

# require_relative "../tap_assert"
# require "awesome_print"
