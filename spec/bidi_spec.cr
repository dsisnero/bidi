require "./spec_helper"

describe Bidi do
  it "has a version number" do
    Bidi::VERSION.should be_a(String)
  end
end

describe Bidi::CharData do
  describe "#bidi_class" do
    it "handles ASCII characters" do
      # Test cases from Rust test_ascii
      Bidi.bidi_class('\u{0000}').should eq(Bidi::BidiClass::BN)
      Bidi.bidi_class('\u{0040}').should eq(Bidi::BidiClass::ON)
      Bidi.bidi_class('\u{0041}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{0062}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{007F}').should eq(Bidi::BidiClass::BN)
    end

    it "handles BMP characters" do
      # Hebrew (R)
      Bidi.bidi_class('\u{0590}').should eq(Bidi::BidiClass::R)
      Bidi.bidi_class('\u{05D0}').should eq(Bidi::BidiClass::R)
      Bidi.bidi_class('\u{05D1}').should eq(Bidi::BidiClass::R)
      Bidi.bidi_class('\u{05FF}').should eq(Bidi::BidiClass::R)

      # Arabic
      Bidi.bidi_class('\u{0600}').should eq(Bidi::BidiClass::AN)
      Bidi.bidi_class('\u{0627}').should eq(Bidi::BidiClass::AL)

      # Default ET
      Bidi.bidi_class('\u{20A0}').should eq(Bidi::BidiClass::ET)
      Bidi.bidi_class('\u{20CF}').should eq(Bidi::BidiClass::ET)

      # Noncharacters (L)
      Bidi.bidi_class('\u{FDD0}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{FDD1}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{FDEE}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{FDEF}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{FFFE}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{FFFF}').should eq(Bidi::BidiClass::L)
    end

    it "handles Supplementary Multilingual Plane (SMP) characters" do
      # Default R + Arabic Letter ranges in SMP
      Bidi.bidi_class('\u{10800}').should eq(Bidi::BidiClass::R)
      Bidi.bidi_class('\u{10FFF}').should eq(Bidi::BidiClass::R)
      Bidi.bidi_class('\u{1E800}').should eq(Bidi::BidiClass::R)
      Bidi.bidi_class('\u{1EDFF}').should eq(Bidi::BidiClass::R)
      Bidi.bidi_class('\u{1EE00}').should eq(Bidi::BidiClass::AL)
      Bidi.bidi_class('\u{1EEFF}').should eq(Bidi::BidiClass::AL)
      Bidi.bidi_class('\u{1EF00}').should eq(Bidi::BidiClass::R)
      Bidi.bidi_class('\u{1EFFF}').should eq(Bidi::BidiClass::R)
    end

    it "handles unassigned code points (default L)" do
      # Unassigned planes should default to L
      Bidi.bidi_class('\u{30000}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{40000}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{50000}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{60000}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{70000}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{80000}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{90000}').should eq(Bidi::BidiClass::L)
      Bidi.bidi_class('\u{a0000}').should eq(Bidi::BidiClass::L)
    end
  end

  describe "#is_rtl" do
    it "returns true for RLE, RLO, RLI" do
      Bidi.rtl?(Bidi::BidiClass::RLE).should be_true
      Bidi.rtl?(Bidi::BidiClass::RLO).should be_true
      Bidi.rtl?(Bidi::BidiClass::RLI).should be_true
    end

    it "returns false for other BidiClass values" do
      Bidi.rtl?(Bidi::BidiClass::L).should be_false
      Bidi.rtl?(Bidi::BidiClass::R).should be_false
      Bidi.rtl?(Bidi::BidiClass::AL).should be_false
      Bidi.rtl?(Bidi::BidiClass::EN).should be_false
    end
  end
end

describe Bidi::Level do
  describe ".create" do
    it "creates valid levels" do
      Bidi::Level.create(0_u8).should eq(Bidi::Level::LTR_LEVEL)
      Bidi::Level.create(1_u8).should eq(Bidi::Level::RTL_LEVEL)
      Bidi::Level.create(10_u8).should be_a(Bidi::Level)
      Bidi::Level.create(125_u8).should be_a(Bidi::Level)
      Bidi::Level.create(126_u8).should be_a(Bidi::Level)
      Bidi::Level.create(127_u8).should eq(Bidi::Level::Error::OutOfRangeNumber)
    end
  end

  describe ".new_explicit" do
    it "creates valid explicit levels" do
      Bidi::Level.new_explicit(0_u8).should eq(Bidi::Level::LTR_LEVEL)
      Bidi::Level.new_explicit(1_u8).should eq(Bidi::Level::RTL_LEVEL)
      Bidi::Level.new_explicit(125_u8).should be_a(Bidi::Level)
      Bidi::Level.new_explicit(126_u8).should eq(Bidi::Level::Error::OutOfRangeNumber)
    end
  end

  describe "#ltr? and #rtl?" do
    it "correctly identifies LTR and RTL levels" do
      Bidi::Level.create(0_u8).as(Bidi::Level).ltr?.should be_true
      Bidi::Level.create(1_u8).as(Bidi::Level).ltr?.should be_false
      Bidi::Level.create(10_u8).as(Bidi::Level).ltr?.should be_true
      Bidi::Level.create(11_u8).as(Bidi::Level).ltr?.should be_false
      Bidi::Level.create(124_u8).as(Bidi::Level).ltr?.should be_true
      Bidi::Level.create(125_u8).as(Bidi::Level).ltr?.should be_false

      Bidi::Level.create(0_u8).as(Bidi::Level).rtl?.should be_false
      Bidi::Level.create(1_u8).as(Bidi::Level).rtl?.should be_true
      Bidi::Level.create(10_u8).as(Bidi::Level).rtl?.should be_false
      Bidi::Level.create(11_u8).as(Bidi::Level).rtl?.should be_true
      Bidi::Level.create(124_u8).as(Bidi::Level).rtl?.should be_false
      Bidi::Level.create(125_u8).as(Bidi::Level).rtl?.should be_true
    end
  end

  describe "#raise and #raise_explicit" do
    it "raises levels correctly" do
      level = Bidi::Level.ltr
      level.number.should eq(0_u8)

      level.raise(100_u8).should be_nil
      level.number.should eq(100_u8)

      level.raise(26_u8).should be_nil
      level.number.should eq(126_u8)

      level.raise(1_u8).should eq(Bidi::Level::Error::OutOfRangeNumber)
      level.number.should eq(126_u8)
    end

    it "raises explicit levels correctly" do
      level = Bidi::Level.ltr
      level.number.should eq(0_u8)

      level.raise_explicit(100_u8).should be_nil
      level.number.should eq(100_u8)

      level.raise_explicit(25_u8).should be_nil
      level.number.should eq(125_u8)

      level.raise_explicit(1_u8).should eq(Bidi::Level::Error::OutOfRangeNumber)
      level.number.should eq(125_u8)
    end
  end

  describe "#lower" do
    it "lowers levels correctly" do
      level = Bidi::Level.rtl
      level.number.should eq(1_u8)

      level.lower(1_u8).should be_nil
      level.number.should eq(0_u8)

      level.lower(1_u8).should eq(Bidi::Level::Error::OutOfRangeNumber)
      level.number.should eq(0_u8)
    end
  end

  describe ".has_rtl?" do
    it "detects RTL levels in arrays" do
      Bidi::Level.has_rtl?(Bidi::Level.vec([0_u8, 0_u8, 0_u8])).should be_false
      Bidi::Level.has_rtl?(Bidi::Level.vec([0_u8, 1_u8, 0_u8])).should be_true
      Bidi::Level.has_rtl?(Bidi::Level.vec([0_u8, 2_u8, 0_u8])).should be_false
      Bidi::Level.has_rtl?(Bidi::Level.vec([0_u8, 125_u8, 0_u8])).should be_true
      Bidi::Level.has_rtl?(Bidi::Level.vec([0_u8, 126_u8, 0_u8])).should be_false
    end
  end

  describe "#bidi_class" do
    it "returns correct BidiClass for level" do
      Bidi::Level.create(0_u8).as(Bidi::Level).bidi_class.should eq(Bidi::BidiClass::L)
      Bidi::Level.create(1_u8).as(Bidi::Level).bidi_class.should eq(Bidi::BidiClass::R)
      Bidi::Level.create(10_u8).as(Bidi::Level).bidi_class.should eq(Bidi::BidiClass::L)
      Bidi::Level.create(11_u8).as(Bidi::Level).bidi_class.should eq(Bidi::BidiClass::R)
    end
  end

  describe "comparisons and conversions" do
    it "compares levels correctly" do
      level1 = Bidi::Level.create(5_u8).as(Bidi::Level)
      level2 = Bidi::Level.create(10_u8).as(Bidi::Level)
      level3 = Bidi::Level.create(5_u8).as(Bidi::Level)

      (level1 < level2).should be_true
      (level1 == level3).should be_true
      (level1 <=> level2).should eq(-1)
    end

    it "converts to string correctly" do
      Bidi::Level.create(0_u8).as(Bidi::Level).to_s.should eq("0")
      Bidi::Level.create(42_u8).as(Bidi::Level).to_s.should eq("42")

      # For conformance tests
      (Bidi::Level.create(0_u8).as(Bidi::Level) == "0").should be_true
      (Bidi::Level.create(1_u8).as(Bidi::Level) == "1").should be_true
      (Bidi::Level.create(4_u8).as(Bidi::Level) == "x").should be_true # "x" matches any level
      (Bidi::Level.create(4_u8).as(Bidi::Level) == "5").should be_false
    end

    it "converts to UInt8" do
      level = Bidi::Level.create(42_u8).as(Bidi::Level)
      level.to_u8.should eq(42_u8)
    end
  end
end
