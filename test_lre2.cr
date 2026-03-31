require "./src/bidi"

lre = Bidi::FormatChars::LRE
puts "LRE char: #{lre.inspect}"
puts "LRE codepoint: 0x#{lre.ord.to_s(16)}"
puts "String length: #{lre.to_s.size}"
puts "String bytes: #{lre.to_s.bytes}"