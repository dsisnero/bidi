require "./src/bidi"

# Test characters from Rust conformance tests
test_chars = {
  "AL"  => '\u{060B}',
  "AN"  => '\u{0605}',
  "EN"  => '\u{06F9}',
  "ES"  => '\u{208B}',
  "ET"  => '\u{20CF}',
  "L"   => '\u{02B8}',
  "NSM" => '\u{0300}',
  "ON"  => '\u{03F6}',
  "R"   => '\u{0590}',
  "S"   => '\u{001F}',
  "WS"  => '\u{200A}',
}

puts "Testing Bidi classes for conformance test characters:"
test_chars.each do |expected_class, char|
  actual_class = Bidi.bidi_class(char)
  puts "U+#{char.ord.to_s(16).rjust(4, '0')} (#{expected_class}): #{actual_class} - #{actual_class == Bidi::BidiClass.parse(expected_class) ? "✓" : "✗"}"
end