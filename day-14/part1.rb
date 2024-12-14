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
map_width = 11
map_height = 7

def find_quadrant(col, boundary)
  split_value = boundary / 2
  Polars.when(col < split_value).then(0).when(col > split_value).then(1).cast(Polars::Int8)
end
translated = data.select(
  Polars.col(:id),
  Polars.col(:sx),
  Polars.col(:sy),
  ((Polars.col(:sx) + Polars.col(:vx) * 100) % map_width).alias("x"),
  ((Polars.col(:sy) + Polars.col(:vy) * 100) % map_height).alias("y")
).with_columns(
  q_x: find_quadrant(Polars.col("x"), map_width),
  q_y: find_quadrant(Polars.col("y"), map_height)
)

# translated.group_by([Polars.col("q_x"), Polars.col("q_y")]).agg(count: Polars.len).collect
g = translated.drop_nulls.group_by([Polars.col("q_x"), Polars.col("q_y")]).agg(count: Polars.len)

def get_result(df)
  df.collect[:count].cumprod[-1]
end

puts get_result(g)
