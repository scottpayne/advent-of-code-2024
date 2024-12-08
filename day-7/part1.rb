Equation = Data.define(:values, :total)

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

  test_values([left + right] + rest, total) || test_values([left * right] + rest, total)
end

puts test_equations(parse_input(File.read(ARGV[0]))).sum(&:total)
