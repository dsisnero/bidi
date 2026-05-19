require "spec"
require "../src/bidi"

describe Bidi::BidiInfo do
  it "creates BidiInfo for simple text" do
    text = "Hello, world!"
    info = Bidi::BidiInfo.new(text)

    info.text.should eq text
    info.paragraphs.size.should eq 1
    info.paragraphs[0].range.begin.should eq 0
    info.paragraphs[0].range.end.should eq text.bytesize
    info.paragraphs[0].level.should eq Bidi::Level.ltr
    info.original_classes.size.should eq text.bytesize
    info.levels.size.should eq text.bytesize
  end

  it "has_rtl? returns false for LTR text" do
    text = "Hello, world!"
    info = Bidi::BidiInfo.new(text)

    info.has_rtl?.should be_false
    info.has_ltr?.should be_true
  end

  it "reordered_levels returns levels for line range" do
    text = "Hello, world!"
    info = Bidi::BidiInfo.new(text)
    para = info.paragraphs[0]

    levels = info.reordered_levels(para, 0...5)
    levels.size.should eq 5
  end

  describe "Paragraph struct" do
    it "provides paragraph-level operations" do
      text = "Hello, world!"
      info = Bidi::BidiInfo.new(text)
      paragraphs = info.paragraphs

      paragraphs.size.should eq 1
      para_info = paragraphs[0]
      para = Bidi::Paragraph.new(info, para_info)

      # Test direction method
      para.direction.should eq Bidi::Direction::Ltr

      # Test level_at method
      (0...5).each do |i|
        para.level_at(i).should eq Bidi::Level.ltr
      end

      # Test access to paragraph info
      para_info.range.begin.should eq 0
      para_info.range.end.should eq text.bytesize
      para_info.level.should eq Bidi::Level.ltr
    end

    it "handles RTL paragraphs" do
      text = "שלום עולם" # "Hello world" in Hebrew
      info = Bidi::BidiInfo.new(text)
      para_info = info.paragraphs[0]
      para = Bidi::Paragraph.new(info, para_info)

      para.direction.should eq Bidi::Direction::Rtl
      para_info.level.rtl?.should be_true
    end

    it "handles mixed-direction paragraphs" do
      text = "Hello שלום"
      info = Bidi::BidiInfo.new(text)
      para_info = info.paragraphs[0]
      para = Bidi::Paragraph.new(info, para_info)

      para.direction.should eq Bidi::Direction::Mixed
    end
  end
end

describe Bidi do
  describe "get_base_direction" do
    it "returns Ltr for empty string" do
      Bidi.get_base_direction("").should eq Bidi::Direction::Ltr
    end

    it "returns Mixed for text with no strong characters" do
      # With full Unicode data, \u{2019} is ON, \u{2060} is BN, \u{00bf} is ON
      # Digits 1-3 are EN (European Number), not L (Left-to-Right)
      # So there are no L, R, or AL characters -> returns Mixed
      Bidi.get_base_direction("123[]-+\u{2019}\u{2060}\u{00bf}?").should eq Bidi::Direction::Mixed
    end

    it "returns Mixed when only first paragraph considered (3.14\\npi)" do
      Bidi.get_base_direction("3.14\npi").should eq Bidi::Direction::Mixed
    end

    it "returns LTR for text with LTR characters ([123 'abc'])" do
      Bidi.get_base_direction("[123 'abc']").should eq Bidi::Direction::Ltr
    end

    it "returns RTL for text with Arabic character ([123 '\\u{0628}' abc)" do
      Bidi.get_base_direction("[123 '\u{0628}' abc").should eq Bidi::Direction::Rtl
    end

    it "returns RTL ignoring embedded isolate ([123 '\\u{2066}abc\\u{2069}'\\u{0628}])" do
      Bidi.get_base_direction("[123 '\u{2066}abc\u{2069}'\u{0628}]").should eq Bidi::Direction::Rtl
    end

    it "returns Mixed for unmatched isolate ([123 '\\u{2066}abc\\u{2068}'\\u{0628}])" do
      Bidi.get_base_direction("[123 '\u{2066}abc\u{2068}'\u{0628}]").should eq Bidi::Direction::Mixed
    end

    it "returns Mixed when only first paragraph considered" do
      Bidi.get_base_direction("3.14\npi").should eq Bidi::Direction::Mixed
    end

    it "returns LTR for LTR text" do
      Bidi.get_base_direction("[123 'abc']").should eq Bidi::Direction::Ltr
    end

    it "returns RTL for RTL text" do
      Bidi.get_base_direction("[123 '\u{0628}' abc").should eq Bidi::Direction::Rtl
    end

    it "ignores embedded isolates" do
      Bidi.get_base_direction("[123 '\u{2066}abc\u{2069}'\u{0628}]").should eq Bidi::Direction::Rtl
    end

    it "returns Mixed for unmatched isolate" do
      Bidi.get_base_direction("[123 '\u{2066}abc\u{2068}'\u{0628}]").should eq Bidi::Direction::Mixed
    end
  end

  describe "get_base_direction_full" do
    it "returns Ltr for empty string" do
      Bidi.get_base_direction_full("").should eq Bidi::Direction::Ltr
    end

    it "returns Mixed for text with no strong characters (get_base_direction_full)" do
      # With full Unicode data, \u{2019} is ON, \u{2060} is BN, \u{00bf} is ON
      # Digits 1-3 are EN (European Number), not L (Left-to-Right)
      # So there are no L, R, or AL characters -> returns Mixed
      Bidi.get_base_direction_full("123[]-+\u{2019}\u{2060}\u{00bf}?").should eq Bidi::Direction::Mixed
    end

    it "takes direction from second paragraph" do
      Bidi.get_base_direction_full("3.14\npi").should eq Bidi::Direction::Ltr
      Bidi.get_base_direction_full("3.14\n\u{05D0}").should eq Bidi::Direction::Rtl
    end

    it "returns LTR for LTR text" do
      Bidi.get_base_direction_full("[123 'abc']").should eq Bidi::Direction::Ltr
    end

    it "returns RTL for RTL text" do
      Bidi.get_base_direction_full("[123 '\u{0628}' abc").should eq Bidi::Direction::Rtl
    end

    it "ignores embedded isolates" do
      Bidi.get_base_direction_full("[123 '\u{2066}abc\u{2069}'\u{0628}]").should eq Bidi::Direction::Rtl
    end

    it "returns Mixed for unmatched isolate" do
      Bidi.get_base_direction_full("[123 '\u{2066}abc\u{2068}'\u{0628}]").should eq Bidi::Direction::Mixed
    end

    it "resets embedding level at newline" do
      Bidi.get_base_direction_full("[123 '\u{2066}abc\u{2068}'\n\u{0628}]").should eq Bidi::Direction::Rtl
    end
  end

  describe "direction tests" do
    it "tests direction for LTR, RTL, and mixed paragraphs" do
      ltr_text = "hello world"
      rtl_text = "أهلا بكم" # Arabic: "Welcome"
      all_paragraphs = "#{ltr_text}\n#{rtl_text}\n#{ltr_text}#{rtl_text}"
      info = Bidi::BidiInfo.new(all_paragraphs)

      info.paragraphs.size.should eq 3

      p_ltr = Bidi::Paragraph.new(info, info.paragraphs[0])
      p_rtl = Bidi::Paragraph.new(info, info.paragraphs[1])
      p_mixed = Bidi::Paragraph.new(info, info.paragraphs[2])

      p_ltr.direction.should eq Bidi::Direction::Ltr
      p_rtl.direction.should eq Bidi::Direction::Rtl
      p_mixed.direction.should eq Bidi::Direction::Mixed
    end

    it "tests edge cases with empty strings and newlines" do
      # Empty text should have no paragraphs
      empty = ""
      info = Bidi::BidiInfo.new(empty, Bidi::Level.rtl)
      info.paragraphs.size.should eq 0

      # Test cases from Rust
      test_cases = [
        {"\n", nil, Bidi::Direction::Ltr},
        {"\n", Bidi::Level.ltr, Bidi::Direction::Ltr},
        {"\n", Bidi::Level.rtl, Bidi::Direction::Rtl},
      ]

      test_cases.each do |text, base_level, expected_direction|
        info = Bidi::BidiInfo.new(text, base_level)
        info.paragraphs.size.should eq 1
        para = Bidi::Paragraph.new(info, info.paragraphs[0])
        para.direction.should eq expected_direction
      end
    end

    it "tests level_at method" do
      ltr_text = "hello world"
      rtl_text = "أهلا بكم"
      all_paragraphs = "#{ltr_text}\n#{rtl_text}\n#{ltr_text}#{rtl_text}"
      info = Bidi::BidiInfo.new(all_paragraphs)

      info.paragraphs.size.should eq 3

      p_ltr = Bidi::Paragraph.new(info, info.paragraphs[0])
      p_rtl = Bidi::Paragraph.new(info, info.paragraphs[1])
      p_mixed = Bidi::Paragraph.new(info, info.paragraphs[2])

      p_ltr.level_at(0).should eq Bidi::Level.ltr
      p_rtl.level_at(0).should eq Bidi::Level.rtl
      p_mixed.level_at(0).should eq Bidi::Level.ltr

      # ltr_text.bytesize gives us the byte position where RTL text starts
      # In the mixed paragraph (ltr_text + rtl_text), after ltr_text bytes we should be in RTL
      p_mixed.level_at(ltr_text.bytesize).should eq Bidi::Level.rtl
    end
  end

  describe "paragraph info tests" do
    it "tests paragraph length" do
      text = "hello world"
      info = Bidi::BidiInfo.new(text)
      info.paragraphs.size.should eq 1
      info.paragraphs[0].length.should eq text.bytesize

      text2 = "How are you"
      whole_text = "#{text}\n#{text2}"
      info = Bidi::BidiInfo.new(whole_text)
      info.paragraphs.size.should eq 2

      # The first paragraph includes the paragraph separator (newline)
      info.paragraphs[0].length.should eq text.bytesize + 1 # +1 for newline
      info.paragraphs[1].length.should eq text2.bytesize
    end
  end

  describe "has_rtl tests" do
    it "correctly detects RTL content" do
      tests = [
        # ASCII only
        {"123", nil, false},
        {"123", Bidi::Level.ltr, false},
        {"123", Bidi::Level.rtl, false},
        {"abc", nil, false},
        {"abc", Bidi::Level.ltr, false},
        {"abc", Bidi::Level.rtl, false},
        {"abc 123", nil, false},
        {"abc\n123", nil, false},
        # With Hebrew
        {"\u{05D0}\u{05D1}\u{05BC}\u{05D2}", nil, true},
        {"\u{05D0}\u{05D1}\u{05BC}\u{05D2}", Bidi::Level.ltr, true},
        {"\u{05D0}\u{05D1}\u{05BC}\u{05D2}", Bidi::Level.rtl, true},
        {"abc \u{05D0}\u{05D1}\u{05BC}\u{05D2}", nil, true},
        {"abc\n\u{05D0}\u{05D1}\u{05BC}\u{05D2}", nil, true},
        {"\u{05D0}\u{05D1}\u{05BC}\u{05D2} abc", nil, true},
        {"\u{05D0}\u{05D1}\u{05BC}\u{05D2}\nabc", nil, true},
        {"\u{05D0}\u{05D1}\u{05BC}\u{05D2} 123", nil, true},
        {"\u{05D0}\u{05D1}\u{05BC}\u{05D2}\n123", nil, true},
      ]

      tests.each do |text, para_level, expected|
        info = Bidi::BidiInfo.new(text, para_level)
        info.has_rtl?.should eq expected
      end
    end
  end

  describe "ParagraphBidiInfo tests" do
    it "handles text with paragraph breaks in single-paragraph API" do
      # Test cases from Rust test_paragraph_bidi_info (lib.rs:1817)
      # The ParagraphBidiInfo API treats embedded paragraph breaks as regular separators
      tests = [
        {
          text:                    "a א.\nג",
          para_level:              nil,
          exp_original_classes_8:  [Bidi::BidiClass::L, Bidi::BidiClass::WS, Bidi::BidiClass::R, Bidi::BidiClass::R, Bidi::BidiClass::CS, Bidi::BidiClass::B, Bidi::BidiClass::R, Bidi::BidiClass::R],
        },
        {
          text:                    "\u{5D1} a.\nb.",
          para_level:              nil,
          exp_original_classes_8:  [Bidi::BidiClass::R, Bidi::BidiClass::R, Bidi::BidiClass::WS, Bidi::BidiClass::L, Bidi::BidiClass::CS, Bidi::BidiClass::B, Bidi::BidiClass::L, Bidi::BidiClass::CS],
        },
        {
          text:                    "a א.\tג",
          para_level:              nil,
          exp_original_classes_8:  [Bidi::BidiClass::L, Bidi::BidiClass::WS, Bidi::BidiClass::R, Bidi::BidiClass::R, Bidi::BidiClass::CS, Bidi::BidiClass::S, Bidi::BidiClass::R, Bidi::BidiClass::R],
        },
      ]

      tests.each do |t|
        info = Bidi::ParagraphBidiInfo.new(t[:text], t[:para_level])
        info.original_classes.should eq t[:exp_original_classes_8]
        info.text.should eq t[:text]
        info.is_pure_ltr.should be_false
      end
    end
  end

  describe "reordered levels range tests" do
    it "produces valid runs for sub-paragraph ranges" do
      # Test from Rust test_reordered_levels_range (lib.rs:2047)
      s = "\u{202A}A\u{202C}\u{202A}A\u{202C}"
      range = 4...11
      bidi = Bidi::BidiInfo.new(s, nil)

      _, runs = bidi.visual_runs(bidi.paragraphs[0], range)

      # All runs should produce valid byte slices of s
      runs.each do |run|
        # Should not raise when slicing
        s.byte_slice(run.begin, run.end - run.begin)
      end
      runs.size.should be > 0
    end
  end
end
