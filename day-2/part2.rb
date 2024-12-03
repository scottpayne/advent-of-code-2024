require 'polars'

def peek(df)
  df.head(10).collect
end

# it's not a CSV but we want to get it into a dataframe somehow so lets pretend
file_name = ARGV[0]
file_name = "input-test.txt"
# file_name = "input.txt"
df = Polars.scan_csv(file_name, has_header: false, row_count_name: "report")

# instead of using lists this time, let's explode the levels and see if we can
# use more performant polars expressions, just for fun
levels = df.select(
  Polars.col("report"),
  Polars.col("column_1").str.split(" ").cast(Polars::List.new(Polars::Int64)).alias("levels")
).explode("levels")
# peek(levels)

# let's use a window function to get the deltas this time
deltas = levels.with_columns(
  delta: Polars.col("levels").diff.over("report")
)
# peek(deltas)

# and we'll get our safe values
criteria = deltas.with_columns(
  increasing: Polars.col("delta") > 0,
  decreasing: Polars.col("delta") < 0,
  within_range: Polars.col("delta").is_between(1, 3) | Polars.col("delta").is_between(-3, -1)
)
peek(criteria)

# and see if things are safe
safe = criteria
  .group_by("report")
  .agg(
    safe: (Polars.col("increasing").all | Polars.col("decreasing").all) & Polars.col("within_range").all,
    increasing: Polars.col("increasing").sum,
    decreasing: Polars.col("decreasing").sum,
    within_range: Polars.col("within_range").sum
  )
peek(safe)

# so now we have our safe reports, let's start looking at the ones that the Problem Dampener can fix
really_safe = safe.select(Polars.col("safe")).sum
really_safe.collect

# use the rle_id to determine how often the direction changes
df50 = criteria.select(
  Polars.col(["report", "levels", "delta", "within_range"]),
  Polars.col("delta").sign.alias("direction"),
).with_columns(
  direction_change: Polars.col("direction").rle_id.over("report")
)
peek(df50)

df50.with_columns(
  prev_delta: Polars.col("delta").shift(1),
).collect