require "./src/bidi"

ltr_text = "hello world"
rtl_text = "أهلا بكم"
mixed_text = ltr_text + rtl_text

info = Bidi::BidiInfo.new(mixed_text)

puts "Checking processing_classes for bytes 24-25 (last Arabic character):"
puts "Byte 24: original_classes[24] = #{info.original_classes[24]}, level = #{info.levels[24]}"
puts "Byte 25: original_classes[25] = #{info.original_classes[25]}, level = #{info.levels[25]}"

# We need to see processing_classes, but it's not exposed in BidiInfo
# Let me trace through the algorithm manually
puts "\nTracing algorithm:"

# Create a ParagraphBidiInfo to see intermediate state
para_info = Bidi::ParagraphBidiInfo.new(mixed_text)
puts "ParagraphBidiInfo created"
puts "Original classes size: #{para_info.original_classes.size}"
puts "Levels size: #{para_info.levels.size}"

# Check specific bytes
(20..25).each do |i|
  puts "Byte #{i}: original=#{para_info.original_classes[i]}, level=#{para_info.levels[i]}"
end
