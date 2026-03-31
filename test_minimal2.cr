require "./src/bidi"

# Test the first conformance test case: LRE should be level "x"
puts "Testing LRE (U+202A):"
lre = Bidi::FormatChars::LRE
text = lre.to_s
puts "Text: #{text.inspect}"

# Test with auto level (nil)
info = Bidi::BidiInfo.new(text, nil)
para_info = info.paragraphs[0]
levels = info.reordered_levels_per_char(para_info, para_info.range)
puts "Auto level - Levels: #{levels.map(&.number)}"
puts "Level == 'x'? #{levels[0] == "x"} (should be true)"

# Test with LTR level
info2 = Bidi::BidiInfo.new(text, Bidi::Level.ltr)
para_info2 = info2.paragraphs[0]
levels2 = info2.reordered_levels_per_char(para_info2, para_info2.range)
puts "LTR level - Levels: #{levels2.map(&.number)}"
puts "Level == 'x'? #{levels2[0] == "x"} (should be true)"

# Test with RTL level
info3 = Bidi::BidiInfo.new(text, Bidi::Level.rtl)
para_info3 = info3.paragraphs[0]
levels3 = info3.reordered_levels_per_char(para_info3, para_info3.range)
puts "RTL level - Levels: #{levels3.map(&.number)}"
puts "Level == 'x'? #{levels3[0] == "x"} (should be true)"