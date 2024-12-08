Equation = Data.define(:values, :total) do
  def to_s
    "#{total}: #{values.join(" ")}"
  end
end

def parse_input(input_text)
  input_text.split("\n").map do |line|
    total, values = line.split(": ")
    Equation.new(
      total: total.to_i,
      values: values.split(" ").map(&:to_i)
    )
  end
end

def test_equations(equations)
  equations.select do |equation|
    test_values(equation.values, equation.total)
  end
end

def test_values(values, total)
  return total == values[0] if values.size == 1
  left, right, *rest = values

  ops = [
    ->(a, b) { a + b },
    ->(a, b) { a * b },
    ->(a, b) { (a.to_s + b.to_s).to_i }
  ]

  ops.any? do |op|
    test_values([op.call(left, right)] + rest, total)
  end
end

successful_equations = test_equations(parse_input(File.read(ARGV[0])))
puts successful_equations.sum(&:total)
