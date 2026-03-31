# Port of the reorder_visual example from Rust unicode-bidi crate
#
# Demonstrates the reorder_visual function which reorders indices based on
# embedding levels without needing the actual text.

require "../src/bidi"

# Create levels
l0 = Bidi::Level.new(0)
l1 = Bidi::Level.new(1)
l2 = Bidi::Level.new(2)

puts "=== Example 1: All LTR levels ==="
levels = [l0, l0, l0, l0]
index_map = Bidi::BidiInfo.reorder_visual(levels)
puts "Levels: #{levels.map(&.value)}"
puts "Index map: #{index_map}"
puts "Expected: [0, 1, 2, 3]"
puts "Match: #{index_map == [0, 1, 2, 3]}"

puts "\n=== Example 2: Mixed levels ==="
levels = [l0, l0, l0, l1, l1, l1, l2, l2]
index_map = Bidi::BidiInfo.reorder_visual(levels)
puts "Levels: #{levels.map(&.value)}"
puts "Index map: #{index_map}"
puts "Expected: [0, 1, 2, 6, 7, 5, 4, 3]"
puts "Match: #{index_map == [0, 1, 2, 6, 7, 5, 4, 3]}"

puts "\n=== Example 3: More complex pattern ==="
levels = [l0, l1, l0, l1, l2, l1, l0]
index_map = Bidi::BidiInfo.reorder_visual(levels)
puts "Levels: #{levels.map(&.value)}"
puts "Index map: #{index_map}"

# Explain what the index map means
puts "\n=== Explanation ==="
puts "The index map shows the visual order of indices."
puts "For example, in Example 2:"
puts "  Visual position 0 -> Logical position 0 (level 0)"
puts "  Visual position 1 -> Logical position 1 (level 0)"
puts "  Visual position 2 -> Logical position 2 (level 0)"
puts "  Visual position 3 -> Logical position 6 (level 2)"
puts "  Visual position 4 -> Logical position 7 (level 2)"
puts "  Visual position 5 -> Logical position 5 (level 1)"
puts "  Visual position 6 -> Logical position 4 (level 1)"
puts "  Visual position 7 -> Logical position 3 (level 1)"
puts ""
puts "This shows that RTL segments (odd levels) are reversed in visual order."

# Demonstrate with actual text
puts "\n=== Applying to text ==="
text = "abcDEFgh"
levels = [l0, l0, l0, l1, l1, l1, l0, l0]  # "abc" (LTR), "DEF" (RTL), "gh" (LTR)

puts "Original text: #{text}"
puts "Levels: #{levels.map(&.value)}"

index_map = Bidi::BidiInfo.reorder_visual(levels)

# Reorder text using index map
visual_text = String.build do |str|
  index_map.each do |logical_index|
    str << text[logical_index]
  end
end

puts "Visual order text: #{visual_text}"
puts "Expected: abcFEDgh"