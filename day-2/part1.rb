require 'polars'

def peek(df)
  df.head(5).collect
end

# it's not a CSV but we want to get it into a dataframe somehow so lets pretend
file_name = ARGV[0]
# file_name = "input-test.txt"
# file_name = "input.txt"
df = Polars.scan_csv(file_name, has_header: false, row_count_name: "report")
levels = df.with_columns(
  Polars.col("column_1").str.split(" ").cast(Polars::List.new(Polars::Int64)).alias("levels")
)
deltas = levels.with_columns(
  levels_delta:
    Polars.col("levels")
      .list.diff
      .list.drop_nulls # call list again for some reason
)
peek(deltas)

safe = deltas.with_columns(
  increasing: Polars.col("levels_delta").list.eval(
    Polars.element > 0
  ).list.all,
  decreasing: Polars.col("levels_delta").list.eval(
    Polars.element < 0
  ).list.all,
  within_range: Polars.col("levels_delta").list.eval(
    Polars.element.is_between(1, 3) | Polars.element.is_between(-3, -1)
  ).list.all,
)

result = safe.select(
  Polars.col("report"),
    (
      Polars.col("within_range") & (Polars.col("increasing") | Polars.col("decreasing"))
    ).alias("safe")
).filter(Polars.col("safe"))
puts result.collect
# peek(result)