require "./src/bidi"

# Reproduce the level_at test failure
ltr_text = "hello world"
rtl_text = "أهلا بكم"
mixed_text = ltr_text + rtl_text

puts "Mixed text: #{mixed_text.inspect}"
puts "LTR text bytesize: #{ltr_text.bytesize}"
puts "RTL text bytesize: #{rtl_text.bytesize}"
puts "Total bytesize: #{mixed_text.bytesize}"

info = Bidi::BidiInfo.new(mixed_text)
para = Bidi::Paragraph.new(info, info.paragraphs[0])

puts "\nParagraph direction: #{para.direction}"
puts "Paragraph level: #{info.paragraphs[0].level}"

# Check levels at key positions
puts "\nLevels at positions:"
puts "  level_at(0): #{para.level_at(0)} (first char, should be LTR)"
puts "  level_at(#{ltr_text.bytesize}): #{para.level_at(ltr_text.bytesize)} (first byte of Arabic, should be RTL=1)"

# Print all levels
puts "\nAll levels (byte positions 0-#{info.levels.size-1}):"
levels = info.levels
(0...levels.size).each do |i|
  level = levels[i]
  if i < ltr_text.bytesize
    # LTR text part
    puts "  #{i}: #{level.number} (LTR text)"
  elsif i < mixed_text.bytesize
    # RTL text part
    puts "  #{i}: #{level.number} (RTL text)"
  else
    puts "  #{i}: #{level.number}"
  end
end

# Also check original classes
puts "\nFirst few original classes:"
(0...[20, info.original_classes.size].min).each do |i|
  puts "  #{i}: #{info.original_classes[i]}"
end
