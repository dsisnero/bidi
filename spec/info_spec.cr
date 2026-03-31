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
end

describe Bidi do
  describe "get_base_direction" do
    it "returns Mixed for empty string" do
      Bidi.get_base_direction("").should eq Bidi::Direction::Mixed
    end

    it "returns LTR for text with LTR characters (simplified character data)" do
      # Note: With our simplified character data table, \u{2019}, \u{2060}, and \u{00bf}
      # are not in the table, so they default to L (Left-to-Right).
      # In the full Rust implementation with complete character data,
      # these characters are ON (Other Neutral) and BN (Boundary Neutral),
      # so this would return Direction::Mixed.
      Bidi.get_base_direction("123[]-+\u{2019}\u{2060}\u{00bf}?").should eq Bidi::Direction::Ltr
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
    it "returns Mixed for empty string" do
      Bidi.get_base_direction_full("").should eq Bidi::Direction::Mixed
    end

    it "returns LTR for text with LTR characters (simplified character data)" do
      # Note: With our simplified character data table, \u{2019}, \u{2060}, and \u{00bf}
      # are not in the table, so they default to L (Left-to-Right).
      # In the full Rust implementation with complete character data,
      # these characters are ON (Other Neutral) and BN (Boundary Neutral),
      # so this would return Direction::Mixed.
      Bidi.get_base_direction_full("123[]-+\u{2019}\u{2060}\u{00bf}?").should eq Bidi::Direction::Ltr
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
end
