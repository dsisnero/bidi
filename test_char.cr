require "./src/bidi"

puts "Testing Bidi class for AFGHANI SIGN (U+060B):"
char = '\u{060B}'
puts "Char: #{char.inspect}"
puts "Code point: 0x#{char.ord.to_s(16)}"
puts "Bidi class: #{Bidi.bidi_class(char)}"
puts "Expected: AL"