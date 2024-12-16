def parse(input_text)
  data = []
  input_text.split("\n").each.with_index do |line, index|
    m = line.match(/p=(?<sx>\d+),(?<sy>\d+) v=(?<vx>-?\d+),(?<vy>-?\d+)/)
    next if m.nil?
    data << {id: index, sx: m[:sx].to_i, sy: m[:sy].to_i, vx: m[:vx].to_i, vy: m[:vy].to_i}
  end
  data
end

require "awesome_print"
require "polars"

input = parse(File.read(ARGV[0]))
data = Polars::LazyFrame.new(input)
# map_width = 11
# map_height = 7
# iterations = 100

map_width = 101
map_height = 103
iterations = 100

def find_quadrant(col, boundary)
  split_value = boundary / 2
  Polars.when(col < split_value).then(0).when(col > split_value).then(1).cast(Polars::Int8)
end
translated = data.select(
  Polars.col(:id),
  Polars.col(:sx),
  Polars.col(:sy),
  ((Polars.col(:sx) + Polars.col(:vx) * iterations) % map_width).alias("x"),
  ((Polars.col(:sy) + Polars.col(:vy) * iterations) % map_height).alias("y")
).with_columns(
  q_x: find_quadrant(Polars.col("x"), map_width),
  q_y: find_quadrant(Polars.col("y"), map_height)
)

def print_grid(df, map_width:, map_height:)
  map = (0...map_height).map do |y|
    (" " * map_width).chars
  end
  df
    .select(Polars.col("x"), Polars.col("y"))
    .sort([Polars.col("x"), Polars.col("y")])
    .collect
    .to_a
    .uniq
    .each { |h| map[h["y"]][h["x"]] = "#" }
  map.each do |row|
    row.each do |val|
      print val
    end
    puts
  end
end

require "pry"
binding.pry

# print_grid(translated, map_width:, map_height:)
translated.sort([Polars.col("x"), Polars.col("y")]).select(
  Polars.col("x"),
  Polars.col("y"),
  Polars.col("x").diff.alias("diff_x"),
  Polars.col("y").diff.alias("diff_y")
).filter((Polars.col("diff_x") == 0) & (Polars.col("diff_y") == 1))
  .group_by(Polars.col("x"))
  .agg(Polars.len)
  .sort(Polars.col("len"))
  .collect
