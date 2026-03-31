require "./src/bidi"

# Test various Arabic characters
test_chars = [
  '\u{060B}',  # AFGHANI SIGN
  '\u{060C}',  # ARABIC COMMA
  '\u{060D}',  # ARABIC DATE SEPARATOR
  '\u{060E}',  # ARABIC POETIC VERSE SIGN
  '\u{060F}',  # ARABIC SIGN MISRA
  '\u{0610}',  # ARABIC SIGN SALLALLAHOU ALAYHE WASSALLAM
  '\u{0627}',  # ARABIC LETTER ALEF
  '\u{0639}',  # ARABIC LETTER AIN
  '\u{0645}',  # ARABIC LETTER MEEM
]

puts "Testing Arabic characters:"
test_chars.each do |char|
  bidi_class = Bidi.bidi_class(char)
  puts "U+#{char.ord.to_s(16).rjust(4, '0')}: #{bidi_class}"
end