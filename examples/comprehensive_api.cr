# Comprehensive API Example
#
# Demonstrates all major APIs of the bidi library, showing how each
# function and method can be used in practice.

require "../src/bidi"

puts "=== Comprehensive bidi API Examples ===\n"

# ----------------------------------------------------------------------
# 1. Basic Direction Detection
# ----------------------------------------------------------------------
puts "1. BASIC DIRECTION DETECTION"
puts "=" * 40

samples = {
  "Hello World" => "LTR text",
  "שלום עולם" => "RTL text",
  "123" => "Neutral (treated as LTR)",
  "Hello 123" => "LTR with numbers",
  "مرحبا 123" => "RTL with numbers",
  "" => "Empty string (LTR)",
  " " => "Whitespace only (LTR)",
  "Hello (שלום) World" => "Mixed direction",
}

samples.each do |text, description|
  direction = Bidi.get_base_direction(text)
  puts "  #{description}:"
  puts "    Text: '#{text}'"
  puts "    Direction: #{direction}"
  puts
end

# ----------------------------------------------------------------------
# 2. BidiInfo API (Multi-paragraph)
# ----------------------------------------------------------------------
puts "\n2. BIDIINFO API (Multi-paragraph text)"
puts "=" * 40

multi_para_text = <<-TEXT
First paragraph in English.
פסקה שנייה בעברית.
Third paragraph with mixed: Hello (שלום) World.
TEXT

puts "Multi-paragraph text:"
puts multi_para_text
puts

bidi_info = Bidi::BidiInfo.new(multi_para_text, nil)

puts "Analysis results:"
puts "  Number of paragraphs: #{bidi_info.paragraphs.size}"
puts "  Has RTL content: #{bidi_info.has_rtl?}"
puts "  Has LTR content: #{bidi_info.has_ltr?}"
puts

bidi_info.paragraphs.each_with_index do |para, i|
  puts "  Paragraph #{i + 1}:"
  puts "    Range: #{para.range}"
  puts "    Level: #{para.level.value} (#{para.level.rtl? ? "RTL" : "LTR"})"
  puts "    Direction: #{para.direction}"

  # Reorder this paragraph
  reordered = bidi_info.reorder_line(para, para.range)
  puts "    Reordered: '#{reordered}'"
  puts
end

# ----------------------------------------------------------------------
# 3. ParagraphBidiInfo API (Single paragraph)
# ----------------------------------------------------------------------
puts "\n3. PARAGRAPHBIDIINFO API (Single paragraph)"
puts "=" * 40

single_text = "Hello שלום World"
puts "Single paragraph text: '#{single_text}'"
puts

para_info = Bidi::ParagraphBidiInfo.new(single_text, nil)

puts "Paragraph info:"
puts "  Level: #{para_info.paragraph_level.value}"
puts "  Direction: #{para_info.paragraph_direction}"

# Reorder the entire text
full_reordered = para_info.reorder_line(0...single_text.bytesize)
puts "  Fully reordered: '#{full_reordered}'"

# Reorder a substring
substring_range = 6...13  # "שלום W"
sub_reordered = para_info.reorder_line(substring_range)
puts "  Substring reordered (#{substring_range}): '#{sub_reordered}'"

# Get visual runs
visual_runs = para_info.visual_runs(0...single_text.bytesize)
puts "  Visual runs: #{visual_runs.size} runs"
visual_runs.each_with_index do |run, i|
  run_text = single_text[run]
  level = para_info.level_at(run.begin)
  puts "    Run #{i + 1}: '#{run_text}' (level #{level.value})"
end

# ----------------------------------------------------------------------
# 4. Level API
# ----------------------------------------------------------------------
puts "\n4. LEVEL API"
puts "=" * 40

# Creating levels
l0 = Bidi::Level.new(0)
l1 = Bidi::Level.new(1)
l2 = Bidi::Level.new(2)

puts "Level examples:"
puts "  Level 0: value=#{l0.value}, rtl?=#{l0.rtl?}, ltr?=#{l0.ltr?}"
puts "  Level 1: value=#{l1.value}, rtl?=#{l1.rtl?}, ltr?=#{l1.ltr?}"
puts "  Level 2: value=#{l2.value}, rtl?=#{l2.rtl?}, ltr?=#{l2.ltr?}"

# Level operations
puts "\nLevel operations:"
puts "  l0.raise(2): #{l0.raise(2).value}"
puts "  l1.lower(1): #{l1.lower(1).value}"
puts "  l0.max(l1): #{l0.max(l1).value}"
puts "  l1.min(l0): #{l1.min(l0).value}"

# ----------------------------------------------------------------------
# 5. reorder_visual API
# ----------------------------------------------------------------------
puts "\n5. REORDER_VISUAL API"
puts "=" * 40

levels = [l0, l0, l1, l1, l0, l2, l2]
puts "Levels: #{levels.map(&.value)}"

index_map = Bidi::BidiInfo.reorder_visual(levels)
puts "Visual index map: #{index_map}"

# Demonstrate what this means
puts "\nVisual order explanation:"
text = "ABCDEFG"
puts "Original text: #{text}"
puts "Levels:        #{levels.map(&.value)}"
puts "Visual order:  #{index_map.map { |i| text[i] }.join}"

# ----------------------------------------------------------------------
# 6. Character Data API
# ----------------------------------------------------------------------
puts "\n6. CHARACTER DATA API"
puts "=" * 40

test_chars = ['A', 'ש', '1', '(', ')', '‪', '‬']

puts "Bidi class for characters:"
test_chars.each do |char|
  bidi_class = Bidi.bidi_class(char)
  puts "  '#{char}' (U+#{char.ord.to_s(16).upcase}): #{bidi_class}"
end

puts "\nRTL check:"
test_chars.each do |char|
  bidi_class = Bidi.bidi_class(char)
  is_rtl = Bidi.rtl?(bidi_class)
  puts "  '#{char}': #{is_rtl ? 'RTL' : 'not RTL'}"
end

# ----------------------------------------------------------------------
# 7. UTF-16 API
# ----------------------------------------------------------------------
puts "\n7. UTF-16 API"
puts "=" * 40

text = "abcאבג"
utf16_text = text.codepoints.map(&.to_u16)

puts "UTF-16 text: '#{text}'"
puts "UTF-16 array: #{utf16_text} (#{utf16_text.size} code units)"

utf16_info = Bidi::UTF16::BidiInfo.new(utf16_text, nil)
para = utf16_info.paragraphs[0]

puts "Analysis:"
puts "  Paragraph level: #{para.level.value}"
puts "  Has surrogate pairs: #{text.any? { |c| c.ord > 0xFFFF }}"

reordered_utf16 = utf16_info.reorder_line(para, 0...utf16_text.size)
reordered_text = String.from_utf16(reordered_utf16)
puts "Reordered: '#{reordered_text}'"

# ----------------------------------------------------------------------
# 8. Error Handling and Edge Cases
# ----------------------------------------------------------------------
puts "\n8. ERROR HANDLING AND EDGE CASES"
puts "=" * 40

edge_cases = [
  "",
  " ",
  "123",
  "\n\n",
  "Hello\nשלום\nWorld",
]

edge_cases.each do |text|
  puts "\nText: #{text.inspect}"

  # Should not raise exceptions
  begin
    direction = Bidi.get_base_direction(text)
    puts "  Base direction: #{direction}"

    if !text.empty? && !text.strip.empty?
      info = Bidi::ParagraphBidiInfo.new(text, nil)
      reordered = info.reorder_line(0...text.bytesize)
      puts "  Reordered: #{reordered.inspect}"
    end
  rescue ex
    puts "  ERROR: #{ex.message}"
  end
end

# ----------------------------------------------------------------------
# 9. Real-world Use Case
# ----------------------------------------------------------------------
puts "\n9. REAL-WORLD USE CASE: Chat Application"
puts "=" * 40

# Simulate chat messages from different users
chat_messages = [
  {user: "Alice", text: "Hello everyone!"},
  {user: "בנימין", text: "שלום לכולם, איך אתם?"},
  {user: "Carlos", text: "Hola (שלום) amigo!"},
  {user: "دينا", text: "مرحبا بالجميع"},
  {user: "Emma", text: "Meeting at 3:00 PM"},
]

puts "Chat transcript:"
chat_messages.each do |msg|
  user = msg[:user]
  text = msg[:text]

  # Determine display direction
  direction = Bidi.get_base_direction(text)

  # Format based on direction
  if direction.rtl?
    formatted = "【#{text}】 #{user}:"
  else
    formatted = "#{user}: #{text}"
  end

  # Reorder if needed
  if direction.mixed?
    info = Bidi::ParagraphBidiInfo.new(text, nil)
    reordered = info.reorder_line(0...text.bytesize)
    formatted = "#{user}: #{reordered}"
  end

  puts "  #{formatted}"
end

puts "\n=== End of Comprehensive Examples ==="