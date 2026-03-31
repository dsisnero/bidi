require "./src/bidi"

puts "Starting test..."
lre_string = Bidi::FormatChars::LRE.to_s

# Test 1: get_base_direction
puts "Test 1: get_base_direction with LRE"
start = Time.instant
result = Bidi.get_base_direction(lre_string)
elapsed = Time.instant - start
puts "  Result: #{result} in #{elapsed.total_milliseconds} ms"

# Test 2: get_base_direction with empty string
puts "\nTest 2: get_base_direction with empty string"
start = Time.instant
result2 = Bidi.get_base_direction("")
elapsed = Time.instant - start
puts "  Result: #{result2} in #{elapsed.total_milliseconds} ms"

# Test 3: BidiInfo.new (should hang)
puts "\nTest 3: BidiInfo.new with LRE (might hang)"
begin
  start = Time.instant
  info = Bidi::BidiInfo.new(lre_string)
  elapsed = Time.instant - start
  puts "  Success! in #{elapsed.total_milliseconds} ms"
rescue ex
  puts "  Exception: #{ex}"
end

puts "\nDone."
