require "./src/bidi"

# Test just one case
puts "Testing minimal case:"
test_case = {
  input_classes: ["LRE"],
  bitset: 0x7,
  exp_levels: ["x"],
  exp_ordering: [] of String,
}

input_classes = test_case[:input_classes]
bitset = test_case[:bitset].to_u8
exp_levels = test_case[:exp_levels]
exp_ordering = test_case[:exp_ordering]

# Generate sample string
input_string = String.build do |str|
  input_classes.each do |class_name|
    case class_name
    when "LRE" then str << Bidi::FormatChars::LRE
    else
      raise "Unknown Bidi class: #{class_name}"
    end
  end
end

puts "Input string: #{input_string.inspect}"
puts "Expected levels: #{exp_levels}"
puts "Expected ordering: #{exp_ordering}"

# Generate base levels from bitset
# Values: auto-LTR, LTR, RTL
values = [nil, Bidi::Level.ltr, Bidi::Level.rtl]
base_levels = (0...values.size).select { |bit| (bitset & (1u8 << bit)) != 0 }
                               .map { |idx| values[idx] }

puts "Base levels to test: #{base_levels}"

base_levels.each do |input_base_level|
  puts "\nTesting with base level: #{input_base_level}"

  # Test UTF-8 API
  bidi_info = Bidi::BidiInfo.new(input_string, input_base_level)

  # Check levels
  para_info = bidi_info.paragraphs[0]
  levels = bidi_info.reordered_levels_per_char(para_info, para_info.range)

  puts "Actual levels: #{levels.map(&.number)}"

  # Compare levels directly
  levels_match = levels.size == exp_levels.size
  if levels_match
    levels.each_with_index do |level, i|
      unless level == exp_levels[i]
        levels_match = false
        puts "Level #{i}: #{level.number} != #{exp_levels[i]}"
        break
      end
    end
  else
    puts "Size mismatch: #{levels.size} != #{exp_levels.size}"
  end

  puts "Levels match? #{levels_match}"
end