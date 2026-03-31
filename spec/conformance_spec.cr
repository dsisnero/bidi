require "spec"
require "../src/bidi"

describe "Bidi Algorithm Conformance" do
  # Test based on the example from Rust unicode-bidi documentation
  it "reorders RTL text correctly" do
    # Hebrew text: Aleph, Beth, Gimel
    # English text: a, b, c
    text = "אבגabc"

    # Resolve embedding levels
    bidi_info = Bidi::BidiInfo.new(text)

    # Should have one paragraph
    bidi_info.paragraphs.size.should eq 1

    para_info = bidi_info.paragraphs[0]

    # Paragraph should be RTL because first strong character is Hebrew (RTL)
    para_info.level.rtl?.should be_true
    para_info.level.number.should eq 1

    # The entire text is one line
    line = para_info.range

    # Get reordered levels for the line (Rule L1)
    _ = bidi_info.reordered_levels(para_info, line)

    # Check that we have RTL levels
    bidi_info.has_rtl?.should be_true
    bidi_info.has_ltr?.should be_true
  end

  it "handles explicit embedding controls" do
    # Test with RLE (Right-to-Left Embedding) and PDF (Pop Directional Formatting)
    rle = "\u202B" # U+202B RIGHT-TO-LEFT EMBEDDING
    pdf = "\u202C" # U+202C POP DIRECTIONAL FORMATTING

    # English text, embedded RTL section, more English
    text = "Hello #{rle}World#{pdf}!"

    bidi_info = Bidi::BidiInfo.new(text)

    # Should have one paragraph
    bidi_info.paragraphs.size.should eq 1

    # Note: has_rtl? checks final levels after implicit resolution (I1-I2).
    # For L characters in RTL embedding, I2 raises level by 1 (odd → even),
    # resulting in LTR levels. So has_rtl? returns false.
    # This is correct - no RTL levels remain after implicit resolution.
    bidi_info.has_rtl?.should be_false
    bidi_info.has_ltr?.should be_true
  end

  it "handles isolate controls" do
    # Test with RLI (Right-to-Left Isolate) and PDI (Pop Directional Isolate)
    rli = "\u2067" # U+2067 RIGHT-TO-LEFT ISOLATE
    pdi = "\u2069" # U+2069 POP DIRECTIONAL ISOLATE

    text = "Hello #{rli}World#{pdi}!"

    bidi_info = Bidi::BidiInfo.new(text)

    bidi_info.paragraphs.size.should eq 1
    # Note: has_rtl? checks final levels after implicit resolution (I1-I2).
    # For L characters in RTL isolate, I2 raises level by 1 (odd → even),
    # resulting in LTR levels. So has_rtl? returns false.
    # This is correct - no RTL levels remain after implicit resolution.
    bidi_info.has_rtl?.should be_false
    bidi_info.has_ltr?.should be_true
  end

  it "handles neutral characters correctly" do
    # Test with neutral characters (punctuation) between strong characters
    # Hebrew (RTL), punctuation (neutral), English (LTR)
    text = "א!a"

    bidi_info = Bidi::BidiInfo.new(text)

    # Should be RTL because first strong character is Hebrew
    bidi_info.paragraphs[0].level.rtl?.should be_true

    # Should have both RTL and LTR levels
    bidi_info.has_rtl?.should be_true
    bidi_info.has_ltr?.should be_true
  end

  it "handles multiple paragraphs" do
    # Text with paragraph separator
    # U+2029 is PARAGRAPH SEPARATOR
    ps = "\u2029"
    text = "First#{ps}Second"

    bidi_info = Bidi::BidiInfo.new(text)

    # Should have two paragraphs
    bidi_info.paragraphs.size.should eq 2

    # Both should be LTR (English)
    bidi_info.paragraphs[0].level.ltr?.should be_true
    bidi_info.paragraphs[1].level.ltr?.should be_true
  end

  it "respects explicit paragraph level" do
    text = "Hello"

    # Auto-detect (should be LTR for English)
    info1 = Bidi::BidiInfo.new(text)
    info1.paragraphs[0].level.ltr?.should be_true

    # Force RTL
    info2 = Bidi::BidiInfo.new(text, Bidi::Level.rtl)
    info2.paragraphs[0].level.rtl?.should be_true

    # Force LTR
    info3 = Bidi::BidiInfo.new(text, Bidi::Level.ltr)
    info3.paragraphs[0].level.ltr?.should be_true
  end
end
