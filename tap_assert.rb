# very simple test library outputing in TAP format
#
# I don't want to introduce Rspec of minitest to do adhoc testing of my puzzle solutions,
# this is a simple inline version for adhoc testing.
def assert(expected, actual, message = "Expect: #{expected}, Actual: #{actual}")
  result = (expected == actual) ? "ok" : "not ok"
  puts "#{result} - #{message}"
end
