#!/usr/bin/env crystal
# Basic example of using the Unicode Bidirectional Algorithm

require "../src/bidi"

# Example text with mixed LTR and RTL characters
# Hebrew text (RTL) followed by English text (LTR)
text = "שלום hello world"

puts "Original text: #{text.inspect}"
puts "Text bytes: #{text.bytes.map(&.to_s(16)).join(' ')}"

# Resolve embedding levels within the text
# Pass nil to detect the paragraph level automatically
bidi_info = Bidi::BidiInfo.new(text, nil)

puts "\nParagraphs: #{bidi_info.paragraphs.size}"
bidi_info.paragraphs.each_with_index do |para, i|
  paragraph = Bidi::Paragraph.new(bidi_info, para)
  puts "  Paragraph #{i}:"
  puts "    Range: #{para.range}"
  puts "    Level: #{para.level} (#{para.level.ltr? ? "LTR" : "RTL"})"
  puts "    Direction: #{paragraph.direction}"
end

# For this example, use a single line that spans the entire paragraph
if bidi_info.paragraphs.size > 0
  para = bidi_info.paragraphs[0]
  line = para.range

  puts "\nReordering line #{line}:"
  display = bidi_info.reorder_line(para, line)
  puts "  Display order: #{display.inspect}"

  # Show visual runs
  levels, runs = bidi_info.visual_runs(para, line)
  puts "  Visual runs:"
  runs.each_with_index do |run, i|
    level = levels[run.begin]?
    text_segment = text[run]
    puts "    Run #{i}: #{run} (level: #{level}, text: #{text_segment.inspect})"
  end
end

# Test get_base_direction
puts "\nBase direction detection:"
puts "  'Hello': #{Bidi.get_base_direction("Hello")}"
puts "  'שלום': #{Bidi.get_base_direction("שלום")}"
puts "  'Hello שלום': #{Bidi.get_base_direction("Hello שלום")}"
puts "  '123': #{Bidi.get_base_direction("123")}"  # Neutral text