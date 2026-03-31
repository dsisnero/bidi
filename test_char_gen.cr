require "./src/bidi"

# Test that sample characters match their Bidi classes
puts "Testing character generation:"

# Test a subset of Bidi classes
test_cases = {
  "AL"  => Bidi::BidiClass::AL,
  "L"   => Bidi::BidiClass::L,
  "R"   => Bidi::BidiClass::R,
  "EN"  => Bidi::BidiClass::EN,
  "ES"  => Bidi::BidiClass::ES,
}

test_cases.each do |class_name, expected_class|
  puts "\nTesting #{class_name}:"

  sample_char = case class_name
  when "AL" then '\u{0627}'  # ARABIC LETTER ALEF (definitely AL)
  when "L"  then '\u{02B8}'  # MODIFIER LETTER SMALL Y
  when "R"  then '\u{0590}'  # HEBREW ACCENT ETNAHTA
  when "EN" then '\u{06F9}'  # EXTENDED ARABIC-INDIC DIGIT NINE
  when "ES" then '\u{208B}'  # SUBSCRIPT MINUS
  else
    raise "Unknown Bidi class: #{class_name}"
  end

  puts "  Sample char: U+#{sample_char.ord.to_s(16)}"

  actual_class = Bidi.bidi_class(sample_char)
  puts "  Expected: #{expected_class}"
  puts "  Actual: #{actual_class}"
  puts "  Match? #{actual_class == expected_class}"

  unless actual_class == expected_class
    puts "  FAILED!"
  end
end