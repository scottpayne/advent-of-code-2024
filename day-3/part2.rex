class MulUp
rule
  do\(\)     { self.state = :DOING; [:do] }
  don\'t\(\) { self.state = :NOT_DOING; [:dont] }
  :DOING mul\((\d+),(\d+)\) { [:mul, text.to_i, text.to_i]}
  .
end