require "./src/bidi"

# Test 1: LRE should be removed by X9
puts "Test 1: LRE character"
lre = Bidi::FormatChars::LRE
text = lre.to_s
info = Bidi::BidiInfo.new(text)
para_info = info.paragraphs[0]
levels = info.reordered_levels_per_char(para_info, para_info.range)
puts "  Text: #{text.inspect}"
puts "  Levels: #{levels.map(&.number)}"
puts "  Expected: [] (removed by X9)"

# Test 2: L character should be level 0
puts "\nTest 2: L character"
l_char = '\u{02B8}'
text = l_char.to_s
info = Bidi::BidiInfo.new(text)
para_info = info.paragraphs[0]
levels = info.reordered_levels_per_char(para_info, para_info.range)
puts "  Text: #{text.inspect}"
puts "  Levels: #{levels.map(&.number)}"
puts "  Expected: [0]"

# Test 3: AL character should be level 1 (in auto detection)
puts "\nTest 3: AL character"
al_char = '\u{0627}'
text = al_char.to_s
info = Bidi::BidiInfo.new(text)
para_info = info.paragraphs[0]
levels = info.reordered_levels_per_char(para_info, para_info.range)
puts "  Text: #{text.inspect}"
puts "  Paragraph level: #{para_info.level.number} (should be 1 for RTL)"
puts "  Levels: #{levels.map(&.number)}"
puts "  Expected: [1]"