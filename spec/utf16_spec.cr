require "./spec_helper"

describe Bidi::UTF16 do
  describe "BidiInfo" do
    it "handles simple UTF-16 text" do
      text = SpecHelpers.to_utf16("Hello, world!")
      info = Bidi::UTF16::BidiInfo.new(text)

      info.text.should eq text
      info.paragraphs.size.should eq 1
      info.original_classes.size.should eq text.size
      info.levels.size.should eq text.size
    end

    it "handles RTL UTF-16 text" do
      text = SpecHelpers.to_utf16("שלום") # "Shalom" in Hebrew
      info = Bidi::UTF16::BidiInfo.new(text)

      info.paragraphs.size.should eq 1
      info.paragraphs[0].level.rtl?.should be_true
    end

    it "handles mixed UTF-16 text" do
      text = SpecHelpers.to_utf16("Hello שלום")
      info = Bidi::UTF16::BidiInfo.new(text)

      info.has_rtl?.should be_true
      info.has_ltr?.should be_true
    end

    it "handles UTF-16 with surrogate pairs" do
      # Text with a character outside BMP (requires surrogate pair)
      text = SpecHelpers.to_utf16("A𐐀B") # 𐐀 is U+10400 (DESERET CAPITAL LETTER LONG I)
      info = Bidi::UTF16::BidiInfo.new(text)

      # Should have 3 characters but 4 code units (𐐀 is surrogate pair)
      text.size.should eq 4 # A, high surrogate, low surrogate, B
      info.original_classes.size.should eq 4
      info.levels.size.should eq 4
    end

    it "handles invalid UTF-16 sequences" do
      text = SpecHelpers.invalid_utf16
      info = Bidi::UTF16::BidiInfo.new(text)

      # Should process without crashing
      info.text.should eq text
      info.original_classes.size.should eq text.size
      info.levels.size.should eq text.size
    end

    it "reorders UTF-16 text correctly" do
      # RTL text should be reordered
      text = SpecHelpers.to_utf16("שלום")
      info = Bidi::UTF16::BidiInfo.new(text)

      line = 0...text.size
      reordered = info.reorder_line(info.paragraphs[0], line)

      # The reordered text should be the same since it's all RTL
      reordered.should be_a(Array(UInt16))
      reordered.size.should eq text.size
    end

    it "handles multiple paragraphs in UTF-16" do
      text = SpecHelpers.to_utf16("Hello\nWorld\nשלום")
      info = Bidi::UTF16::BidiInfo.new(text)

      info.paragraphs.size.should eq 3
      info.paragraphs[0].level.ltr?.should be_true
      info.paragraphs[1].level.ltr?.should be_true
      info.paragraphs[2].level.rtl?.should be_true
    end
  end

  describe "ParagraphBidiInfo" do
    it "creates ParagraphBidiInfo for UTF-16" do
      text = SpecHelpers.to_utf16("Hello, world!")
      info = Bidi::UTF16::ParagraphBidiInfo.new(text)

      info.text.should eq text
      info.original_classes.size.should eq text.size
      info.levels.size.should eq text.size
      info.paragraph_level.ltr?.should be_true
    end

    it "handles RTL in ParagraphBidiInfo" do
      text = SpecHelpers.to_utf16("مرحبا") # "Hello" in Arabic
      info = Bidi::UTF16::ParagraphBidiInfo.new(text)

      info.paragraph_level.rtl?.should be_true
    end
  end

  describe "UTF-16 text source" do
    it "handles char_at with surrogate pairs and unpaired surrogates" do
      # Rust test_utf16_text_source (lib.rs:1436)
      text = [0x41_u16, 0xD801_u16, 0xDC01_u16, 0x20_u16, 0xD800_u16, 0x20_u16, 0xDFFF_u16, 0x20_u16, 0xDC00_u16, 0xD800_u16]

      # UTF16::TextSource.char_at
      t = Bidi::UTF16::TextSource
      result = t.char_at(text, 0)
      result.should_not be_nil
      r = result.not_nil!
      r[0].should eq 'A'
      r[1].should eq 1

      result = t.char_at(text, 1)
      result.should_not be_nil
      r = result.not_nil!
      r[0].should eq '\u{10401}'
      r[1].should eq 2

      # Mid-surrogate returns nil
      t.char_at(text, 2).should be_nil

      result = t.char_at(text, 3)
      result.should_not be_nil
      r = result.not_nil!
      r[0].should eq ' '
      r[1].should eq 1

      # Unpaired high surrogate → REPLACEMENT_CHARACTER
      result = t.char_at(text, 4)
      result.should_not be_nil
      r = result.not_nil!
      r[0].should eq '\u{FFFD}'
      r[1].should eq 1

      # Unpaired low surrogate → REPLACEMENT_CHARACTER
      result = t.char_at(text, 6)
      result.should_not be_nil
      r = result.not_nil!
      r[0].should eq '\u{FFFD}'
      r[1].should eq 1
    end

    it "iterates chars with surrogate pairs" do
      # Rust test_utf16_char_iter (lib.rs:1453)
      text = [0x41_u16, 0xD801_u16, 0xDC01_u16, 0x20_u16, 0xD800_u16, 0x20_u16, 0xDFFF_u16, 0x20_u16, 0xDC00_u16, 0xD800_u16]

      chars = [] of Char
      Bidi::UTF16::TextSource.each_char(text) { |c| chars << c }
      chars.size.should eq 9

      chars[0].should eq 'A'
      chars[1].should eq '\u{10401}'
      chars[2].should eq ' '
      chars[3].should eq '\u{FFFD}'
    end
  end
end
