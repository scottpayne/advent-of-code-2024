# rules = <<~EOT
#   47|53
#   97|13
#   97|61
#   97|47
#   75|29
#   61|13
#   75|53
#   29|13
#   97|29
#   53|29
#   61|53
#   97|53
#   61|29
#   47|13
#   75|47
#   97|75
#   47|61
#   75|61
#   47|29
#   75|13
#   53|13
# EOT

# page_orders = <<~EOT
#   75,47,61,53,29
#   97,61,53,29,13
#   75,29,13
#   75,97,47,61,53
#   61,13,29
#   97,13,75,29,47
# EOT

rules = File.read("rules.txt")
page_orders = File.read("page_orders.txt")
# rules = File.read("rules-test.txt")
# page_orders = File.read("page_orders_test.txt")

rules = rules.split("\n").map(&:chomp).map { |rule| rule.split("|") }
page_orders = page_orders.split("\n").map(&:chomp).map { |page_order| page_order.split(",") }

def violates_rule?(page_order, rule)
  first = rule[0]
  second = rule[1]
  first_idx = page_order.index(first)
  second_idx = page_order.index(second)
  !(first_idx.nil? || second_idx.nil?) && first_idx > second_idx
end

incorrect_page_orders = page_orders.select do |page_order|
  rules.any? do |rule|
    violates_rule?(page_order, rule)
  end
end

h = {}
rules.each do |(first, second)|
  h[first] ||= []
  h[first] << second
end

comparator = ->(x, y) do
  if !h[x].nil? && h[x].include?(y)
    -1
  elsif !h[y].nil? && h[y].include?(x)
    1
  else
    0
  end
end

fixed = incorrect_page_orders.map do |page_order|
  page_order.sort(&comparator)
end

middle_pages = fixed.map { |page_order| page_order[page_order.length / 2].to_i }

puts middle_pages.sum
