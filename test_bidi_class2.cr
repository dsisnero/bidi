require "./src/bidi"

lre = '\u{202A}'
puts "Bidi.bidi_class(#{lre.inspect}): #{Bidi.bidi_class(lre)}"

# Test HardcodedBidiData directly
data = Bidi::HardcodedBidiData.new
puts "HardcodedBidiData.new.bidi_class(#{lre.inspect}): #{data.bidi_class(lre)}"
