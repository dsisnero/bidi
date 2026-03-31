require "./src/bidi"

# Test bidi_class directly
lre_char = '\u{202A}'
puts "Testing bidi_class for LRE (U+202A)..."

# Call bidi_class
start_time = Time.monotonic
result = Bidi.bidi_class(lre_char)
elapsed = Time.monotonic - start_time

puts "Result: #{result}"
puts "Time: #{elapsed.total_milliseconds} ms"

if elapsed > 1.second
  puts "TOO SLOW - possible infinite loop!"
end

# Test with other characters
puts "\nTesting other characters:"
test_chars = ['A', 'א', '1', '\u{202B}']  # RLE
test_chars.each do |c|
  start = Time.monotonic
  result = Bidi.bidi_class(c)
  elapsed = Time.monotonic - start
  puts "  #{c.inspect} (U+#{c.ord.to_s(16).upcase}): #{result} in #{elapsed.total_milliseconds} ms"
end
