require "./src/bidi"

ltr_text = "hello world"
rtl_text = "أهلا بكم"
mixed_text = ltr_text + rtl_text

puts "Creating BidiInfo..."
info = Bidi::BidiInfo.new(mixed_text)

puts "\nChecking levels..."
puts "Byte 24: level=#{info.levels[24]}"
puts "Byte 25: level=#{info.levels[25]}"
