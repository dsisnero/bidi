# Port of the main Rust example from unicode-bidi/src/lib.rs
#
# This example demonstrates basic bidi text analysis and reordering,
# matching the behavior shown in the Rust crate documentation.

require "../src/bidi"

# This example text uses separate strings because some browsers
# and text editors have trouble displaying bidi strings.
text = "א" + "ב" + "ג" + "a" + "b" + "c"

# Resolve embedding levels within the text. Pass `nil` to detect the
# paragraph level automatically.
bidi_info = Bidi::BidiInfo.new(text, nil)

# This paragraph has embedding level 1 because its first strong character is RTL.
puts "Number of paragraphs: #{bidi_info.paragraphs.size}"
para = bidi_info.paragraphs[0]
puts "Paragraph level: #{para.level.value}"
puts "Paragraph is RTL: #{para.level.rtl?}"

# Re-ordering is done after wrapping each paragraph into a sequence of
# lines. For this example, I'll just use a single line that spans the
# entire paragraph.
line = para.range

display = bidi_info.reorder_line(para, line)
expected = "a" + "b" + "c" + "ג" + "ב" + "א"

puts "Original text: #{text}"
puts "Reordered text: #{display}"
puts "Expected text: #{expected}"
puts "Match: #{display == expected}"

# Additional verification
puts "\nVerification:"
puts "  Paragraph range: #{para.range}"
puts "  Paragraph level indicates RTL: #{para.level.rtl?}"
puts "  Has RTL: #{bidi_info.has_rtl?}"
puts "  Has LTR: #{bidi_info.has_ltr?}"

# Show level for each character
puts "\nCharacter levels:"
text.each_char_with_index do |char, i|
  level = bidi_info.levels[i]
  puts "  '#{char}' at position #{i}: level #{level.value} (#{level.rtl? ? "RTL" : "LTR"})"
end