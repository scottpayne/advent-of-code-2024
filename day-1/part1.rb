#!/usr/bin/env ruby


require 'polars'

df = Polars.scan_csv("input.txt", has_header: false)

df2a = df.select(
  Polars.col("column_1").str.extract_groups('^(?<a>\d+)\s+(?<b>\d+)$')
)

df2b = df2a.unnest("column_1").with_columns(
  Polars.col("a").cast(Polars::Int64),
  Polars.col("b").cast(Polars::Int64)
)

sorted = df2b.select(Polars.col(["a", "b"]).sort())

distance = sorted.select((Polars.col("a") - Polars.col("b")).abs().alias("distance")).sum().collect

puts "Distance: #{distance["distance"][0]}"
