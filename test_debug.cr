require "./src/bidi"

ltr_text = "hello world"
rtl_text = "أهلا بكم"
mixed_text = ltr_text + rtl_text

puts "Creating BidiInfo..."
info = Bidi::BidiInfo.new(mixed_text)

puts "\nFinal levels bytes 20-25:"
(20..25).each do |i|
  puts "  Byte #{i}: level=#{info.levels[i]}"
end
