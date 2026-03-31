# UTF-16 example demonstrating bidi processing for UTF-16 encoded text
#
# Shows how to work with UTF-16 text (Array(UInt16)) which is common in
# systems like Windows APIs, JavaScript, and some file formats.

require "../src/bidi"

puts "=== UTF-16 Bidi Processing Example ==="

# Example 1: Basic UTF-16 text
text = "abcאבג"  # "abc" (LTR) + Hebrew "ABC" (RTL)
puts "Original text: #{text}"

# Convert to UTF-16 (Array(UInt16))
utf16_text = text.codepoints.map(&.to_u16)
puts "UTF-16 code units: #{utf16_text.size}"
puts "UTF-16 values: #{utf16_text}"

# Analyze UTF-16 text
info = Bidi::UTF16::BidiInfo.new(utf16_text, nil)
para = info.paragraphs[0]

puts "\nAnalysis:"
puts "  Number of paragraphs: #{info.paragraphs.size}"
puts "  Paragraph level: #{para.level.value}"
# Note: ParagraphInfo doesn't have direction method
# Direction would be determined from para.level.rtl?
puts "  Has RTL: #{info.has_rtl?}"
puts "  Has LTR: #{info.has_ltr?}"

# Reorder returns Array(UInt16)
reordered_utf16 = info.reorder_line(para, 0...utf16_text.size)

# Convert back to string
reordered_string = String.from_utf16(reordered_utf16)
puts "\nReordered text: #{reordered_string}"
puts "Expected: abcגבא"

# Example 2: Text with surrogate pairs (characters outside BMP)
puts "\n=== Example 2: Text with surrogate pairs ==="
text2 = "Hello 𐐷𐐷 World"  # "𐐷" is U+10437 DESERET SMALL LETTER YEE (needs surrogate pair)
puts "Text with surrogate pair: #{text2}"
puts "Length in characters: #{text2.size}"
puts "Length in code points: #{text2.codepoints.size}"

utf16_text2 = text2.codepoints.map(&.to_u16)
puts "UTF-16 code units: #{utf16_text2.size}"

info2 = Bidi::UTF16::BidiInfo.new(utf16_text2, nil)
para2 = info2.paragraphs[0]

# Show that surrogate pairs are handled correctly
puts "\nCharacter analysis:"
text2.each_char_with_index do |char, i|
  level = info2.level_at(i)
  puts "  '#{char}' (U+#{char.ord.to_s(16).upcase}) at #{i}: level #{level.value}"
end

# Example 3: Mixed RTL/LTR with numbers
puts "\n=== Example 3: Mixed content with numbers ==="
text3 = "Price: 100₪ for item #123"  # Includes shekel sign (U+20AA)
puts "Mixed content: #{text3}"

utf16_text3 = text3.codepoints.map(&.to_u16)
info3 = Bidi::UTF16::BidiInfo.new(utf16_text3, nil)
para3 = info3.paragraphs[0]

reordered_utf16_3 = info3.reorder_line(para3, 0...utf16_text3.size)
reordered_string3 = String.from_utf16(reordered_utf16_3)
puts "Reordered: #{reordered_string3}"

# Example 4: Comparing UTF-8 and UTF-16 results
puts "\n=== Example 4: UTF-8 vs UTF-16 comparison ==="
test_text = "Hello שלום"

# UTF-8 processing
utf8_info = Bidi::BidiInfo.new(test_text, nil)
utf8_para = utf8_info.paragraphs[0]
utf8_reordered = utf8_info.reorder_line(utf8_para, utf8_para.range)

# UTF-16 processing
utf16_test = test_text.codepoints.map(&.to_u16)
utf16_info = Bidi::UTF16::BidiInfo.new(utf16_test, nil)
utf16_para = utf16_info.paragraphs[0]
utf16_reordered_array = utf16_info.reorder_line(utf16_para, 0...utf16_test.size)
utf16_reordered = String.from_utf16(utf16_reordered_array)

puts "Original: #{test_text}"
puts "UTF-8 reordered: #{utf8_reordered}"
puts "UTF-16 reordered: #{utf16_reordered}"
puts "Results match: #{utf8_reordered == utf16_reordered}"

# Show that levels are the same
puts "\nLevel comparison (first 10 positions):"
10.times do |i|
  break if i >= test_text.size
  utf8_level = utf8_info.level_at(i)
  utf16_level = utf16_info.level_at(i)
  puts "  Position #{i}: UTF-8 level #{utf8_level.value}, UTF-16 level #{utf16_level.value}, match: #{utf8_level.value == utf16_level.value}"
end