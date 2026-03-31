require "./src/bidi"

# Test just LRE
puts "Testing LRE:"
lre = Bidi::FormatChars::LRE
text = lre.to_s
info = Bidi::BidiInfo.new(text)
para_info = info.paragraphs[0]
levels = info.reordered_levels_per_char(para_info, para_info.range)
puts "  Text: #{text.inspect} (length: #{text.size} chars, #{text.bytesize} bytes)"
puts "  Levels: #{levels.map(&.number)}"
puts "  Expected: [] (removed by X9)"

# Filter out characters removed by X9
exp_levels = ["x"]
actual_levels_filtered = [] of String
levels.each_with_index do |level, i|
  if exp_levels[i] != "x"
    actual_levels_filtered << level.number.to_s
  end
end
exp_levels_filtered = exp_levels.reject("x")

puts "  Filtered expected: #{exp_levels_filtered}"
puts "  Filtered actual: #{actual_levels_filtered}"
puts "  Match? #{actual_levels_filtered == exp_levels_filtered}"