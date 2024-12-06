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

# rules = File.read("rules.txt")
# page_orders = File.read("page_orders.txt")
rules = File.read("rules.txt")
page_orders = File.read("page_orders.txt")

rules = rules.split("\n").map(&:chomp).map { |rule| rule.split("|") }
page_orders = page_orders.split("\n").map(&:chomp).map { |page_order| page_order.split(",") }

correct_page_orders = page_orders.select do |page_order|
  rules.all? do |rule|
    first = rule[0]
    second = rule[1]
    if page_order.include?(first) && page_order.include?(second)
      (page_order in [*, ^first, *tail]) and (tail in [*, ^second, *])
    else
      true
    end
  end
end

middle_pages = correct_page_orders.map { |page_order| page_order[page_order.length / 2].to_i }

puts middle_pages.sum
