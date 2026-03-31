require "./src/bidi"

# Minimal test with LRE character
lre_char = Bidi::FormatChars::LRE
lre_string = lre_char.to_s
puts "LRE string: #{lre_string.inspect} (U+#{lre_char.ord.to_s(16).upcase})"
puts "LRE bytesize: #{lre_string.bytesize}"

# Test get_base_direction with LRE (should not hang)
puts "\nTesting get_base_direction with LRE:"
result = Bidi.get_base_direction(lre_string)
puts "Result: #{result}"

# Test with empty string
puts "\nTesting get_base_direction with empty string:"
result2 = Bidi.get_base_direction("")
puts "Result: #{result2}"
