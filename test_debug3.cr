require "./src/bidi"

ltr_text = "hello world"
rtl_text = "أهلا بكم"
mixed_text = ltr_text + rtl_text

puts "Creating BidiInfo..."
info = Bidi::BidiInfo.new(mixed_text)

puts "\nText bytesize: #{mixed_text.bytesize}"
puts "Levels size: #{info.levels.size}"
