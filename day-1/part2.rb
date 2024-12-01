#!/usr/bin/env ruby

require 'polars'

def scan_fixed_width(filename)
  Polars.scan_csv(filename, has_header: false)
    .select(
      Polars.col("column_1").str.extract_groups('^(?<a>\d+)\s+(?<b>\d+)$')
    ).unnest("column_1").with_columns(
      Polars.col("a").cast(Polars::Int64),
      Polars.col("b").cast(Polars::Int64)
    )
end

df = scan_fixed_width("input.txt")

freq = df.group_by(["b"]).agg(Polars.length.alias("b_freq"))

similarity_score =
  df.select(Polars.col("a"))
    .join(freq, how: "left", left_on: Polars.col("a"), right_on: Polars.col("b"))
    .select(
      (Polars.col("a") * Polars.col("b_freq")).alias("similarity_score")
    )
    .sum
    .collect

puts "Similarity score: #{similarity_score["similarity_score"][0]}"