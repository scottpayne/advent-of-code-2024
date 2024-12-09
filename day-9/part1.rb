DiskMap = Data.define(:blocks)

BlockRun = Data.define(:count, :contents)
FileBlocks = Data.define(:id)
FreeSpace = Data.define

def parse(input_line)
  input_line.chars.each_slice(2).flat_map.with_index do |pair, index|
    [
      BlockRun.new(count: pair[0], contents: FileBlocks.new(id: index)),
      BlockRun.new(count: pair[1], contents: FreeSpace.new)
    ].reject { |block_run| block_run in BlockRun(count: nil) }
  end
end

input = File.read(ARGV[0]).chomp("\n")
require "awesome_print"
ap parse(input)
