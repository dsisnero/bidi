require "spec"
require "../src/bidi"

# Simple conformance test that processes a small subset of test data
# This is for development/debugging - full conformance tests are in conformance_full_spec.cr

describe "Bidi Algorithm Simple Conformance" do
  # Test a few specific cases from BidiTest.txt
  it "handles basic test cases" do
    # These are the first few test cases from BidiTest.txt
    test_cases = [
      {
        input_classes: ["LRE"],
        bitset:        0x7, # auto-LTR, LTR, RTL
        exp_levels:    ["x"],
        exp_ordering:  [] of String,
      },
      {
        input_classes: ["L"],
        bitset:        0x3, # auto-LTR, LTR (not RTL)
        exp_levels:    ["0"],
        exp_ordering:  ["0"],
      },
      {
        input_classes: ["R"],
        bitset:        0x7, # auto-LTR, LTR, RTL
        exp_levels:    ["1"],
        exp_ordering:  ["0"],
      },
      {
        input_classes: ["AL"],
        bitset:        0x7, # auto-LTR, LTR, RTL
        exp_levels:    ["1"],
        exp_ordering:  ["0"],
      },
    ]

    test_cases.each_with_index do |test_case, idx|
      input_classes = test_case[:input_classes]
      bitset = test_case[:bitset].to_u8
      exp_levels = test_case[:exp_levels]
      exp_ordering = test_case[:exp_ordering]

      # Generate sample string
      input_string = String.build do |str|
        input_classes.each do |class_name|
          case class_name
          when "AL"  then str << '\u{0627}' # ARABIC LETTER ALEF (definitely AL)
          when "AN"  then str << '\u{0605}' # ARABIC NUMBER MARK
          when "B"   then str << '\u{000A}' # LINE FEED
          when "BN"  then str << '\u{2060}' # WORD JOINER
          when "CS"  then str << '\u{2044}' # FRACTION SLASH
          when "EN"  then str << '\u{06F9}' # EXTENDED ARABIC-INDIC DIGIT NINE
          when "ES"  then str << '\u{208B}' # SUBSCRIPT MINUS
          when "ET"  then str << '\u{20CF}' # DRACHMA SIGN
          when "FSI" then str << Bidi::FormatChars::FSI
          when "L"   then str << '\u{02B8}' # MODIFIER LETTER SMALL Y
          when "LRE" then str << Bidi::FormatChars::LRE
          when "LRI" then str << Bidi::FormatChars::LRI
          when "LRO" then str << Bidi::FormatChars::LRO
          when "NSM" then str << '\u{0300}' # COMBINING GRAVE ACCENT
          when "ON"  then str << '\u{03F6}' # GREEK REVERSED LUNATE EPSILON SYMBOL
          when "PDF" then str << Bidi::FormatChars::PDF
          when "PDI" then str << Bidi::FormatChars::PDI
          when "R"   then str << '\u{0590}' # HEBREW ACCENT ETNAHTA
          when "RLE" then str << Bidi::FormatChars::RLE
          when "RLI" then str << Bidi::FormatChars::RLI
          when "RLO" then str << Bidi::FormatChars::RLO
          when "S"   then str << '\u{001F}' # UNIT SEPARATOR
          when "WS"  then str << '\u{200A}' # HAIR SPACE
          else
            raise "Unknown Bidi class: #{class_name}"
          end
        end
      end

      # Generate base levels from bitset
      # Values: auto-LTR, LTR, RTL
      values = [nil, Bidi::Level.ltr, Bidi::Level.rtl]
      base_levels = (0...values.size).select { |bit| (bitset & (1u8 << bit)) != 0 }
        .map { |idx| values[idx] }

      base_levels.each do |input_base_level|
        # Test UTF-8 API
        bidi_info = Bidi::BidiInfo.new(input_string, input_base_level)

        # Check levels
        para_info = bidi_info.paragraphs[0]
        levels = bidi_info.reordered_levels_per_char(para_info, para_info.range)

        reorder_map = Bidi::BidiInfo.reorder_visual(levels)

        # Filter out characters with level 'x' (ignored in reordering)
        actual_ordering = reorder_map.select do |logical_idx|
          logical_idx < exp_levels.size && exp_levels[logical_idx] != "x"
        end.map(&.to_s)

        # Compare levels directly - Level == String handles "x" specially
        levels_match = levels.size == exp_levels.size
        if levels_match
          levels.each_with_index do |level, i|
            unless level == exp_levels[i]
              levels_match = false
              break
            end
          end
        end

        if !levels_match || actual_ordering != exp_ordering
          puts "Test case #{idx} failed:"
          puts "  Input classes: #{input_classes}"
          puts "  Input string: #{input_string.inspect}"
          puts "  Base level: #{input_base_level}"
          puts "  Expected levels: #{exp_levels}"
          puts "  Actual levels: #{levels.map(&.number)}"
          puts "  Expected ordering: #{exp_ordering}"
          puts "  Actual ordering: #{actual_ordering}"
          puts "  Reorder map: #{reorder_map}"
        end

        levels_match.should be_true, "Test case #{idx}: levels mismatch"
        actual_ordering.should eq(exp_ordering), "Test case #{idx}: ordering mismatch"
      end
    end
  end

  # Test character conformance with a few simple cases
  it "handles simple character test cases" do
    # Simple test: L character should be level 0
    test_cases = [
      {
        input_chars:          ['\u{02B8}'], # L class
        input_base_level_idx: 0,            # LTR
        exp_base_level:       0,
        exp_levels:           ["0"],
        exp_ordering:         ["0"],
      },
      {
        input_chars:          ['\u{0590}'], # R class
        input_base_level_idx: 0,            # LTR
        exp_base_level:       1,            # First strong char is R, so paragraph is RTL
        exp_levels:           ["1"],
        exp_ordering:         ["0"],
      },
    ]

    test_cases.each_with_index do |test_case, idx|
      input_chars = test_case[:input_chars]
      input_string = String.build { |str| input_chars.each { |c| str << c } }

      # Generate base level from index
      # Values: LTR, RTL, auto-LTR
      values = [Bidi::Level.ltr, Bidi::Level.rtl, nil]
      input_base_level = values[test_case[:input_base_level_idx]]

      exp_base_level = Bidi::Level.new(test_case[:exp_base_level].to_u8)
      exp_levels = test_case[:exp_levels]
      exp_ordering = test_case[:exp_ordering]

      bidi_info = Bidi::BidiInfo.new(input_string, input_base_level)

      # Check levels
      para_info = bidi_info.paragraphs[0]
      levels = bidi_info.reordered_levels_per_char(para_info, para_info.range)

      reorder_map = Bidi::BidiInfo.reorder_visual(levels)

      # Filter out characters with level 'x' (ignored in reordering)
      actual_ordering = reorder_map.select do |logical_idx|
        logical_idx < exp_levels.size && exp_levels[logical_idx] != "x"
      end.map(&.to_s)

      # Compare levels directly - Level == String handles "x" specially
      levels_match = levels.size == exp_levels.size
      if levels_match
        levels.each_with_index do |level, i|
          unless level == exp_levels[i]
            levels_match = false
            break
          end
        end
      end

      # Check paragraph level
      actual_base_level = para_info.level
      actual_base_level.should eq(exp_base_level), "Test case #{idx}: paragraph level mismatch"

      if !levels_match || exp_ordering != actual_ordering
        puts "Test case #{idx} failed:"
        puts "  Input chars: #{input_chars.map(&.ord.to_s(16))}"
        puts "  Input string: #{input_string.inspect}"
        puts "  Base level: #{input_base_level}"
        puts "  Expected base level: #{exp_base_level}"
        puts "  Actual base level: #{actual_base_level}"
        puts "  Expected levels: #{exp_levels}"
        puts "  Actual levels: #{levels.map(&.number)}"
        puts "  Expected ordering: #{exp_ordering}"
        puts "  Actual ordering: #{actual_ordering}"
      end

      levels_match.should be_true, "Test case #{idx}: levels mismatch"
      actual_ordering.should eq(exp_ordering), "Test case #{idx}: ordering mismatch"
    end
  end

  # Test that sample characters match their Bidi classes
  it "generates correct sample characters for Bidi classes" do
    # Test a subset of Bidi classes
    test_cases = {
      "AL" => Bidi::BidiClass::AL,
      "L"  => Bidi::BidiClass::L,
      "R"  => Bidi::BidiClass::R,
      "EN" => Bidi::BidiClass::EN,
      "ES" => Bidi::BidiClass::ES,
    }

    test_cases.each do |class_name, expected_class|
      sample_char = case class_name
                    when "AL"  then '\u{0627}' # ARABIC LETTER ALEF (definitely AL)
                    when "AN"  then '\u{0605}' # ARABIC NUMBER MARK
                    when "B"   then '\u{000A}' # LINE FEED
                    when "BN"  then '\u{2060}' # WORD JOINER
                    when "CS"  then '\u{2044}' # FRACTION SLASH
                    when "EN"  then '\u{06F9}' # EXTENDED ARABIC-INDIC DIGIT NINE
                    when "ES"  then '\u{208B}' # SUBSCRIPT MINUS
                    when "ET"  then '\u{20CF}' # DRACHMA SIGN
                    when "FSI" then Bidi::FormatChars::FSI
                    when "L"   then '\u{02B8}' # MODIFIER LETTER SMALL Y
                    when "LRE" then Bidi::FormatChars::LRE
                    when "LRI" then Bidi::FormatChars::LRI
                    when "LRO" then Bidi::FormatChars::LRO
                    when "NSM" then '\u{0300}' # COMBINING GRAVE ACCENT
                    when "ON"  then '\u{03F6}' # GREEK REVERSED LUNATE EPSILON SYMBOL
                    when "PDF" then Bidi::FormatChars::PDF
                    when "PDI" then Bidi::FormatChars::PDI
                    when "R"   then '\u{0590}' # HEBREW ACCENT ETNAHTA
                    when "RLE" then Bidi::FormatChars::RLE
                    when "RLI" then Bidi::FormatChars::RLI
                    when "RLO" then Bidi::FormatChars::RLO
                    when "S"   then '\u{001F}' # UNIT SEPARATOR
                    when "WS"  then '\u{200A}' # HAIR SPACE
                    else
                      raise "Unknown Bidi class: #{class_name}"
                    end

      actual_class = Bidi.bidi_class(sample_char)
      actual_class.should eq(expected_class), "Class #{class_name}: expected #{expected_class}, got #{actual_class} for char #{sample_char.ord.to_s(16)}"
    end
  end
end
