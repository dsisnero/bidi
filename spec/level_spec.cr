require "./spec_helper"

describe Bidi::Level do
  describe ".new" do
    it "creates valid levels" do
      Bidi::Level.create(0).should be_a(Bidi::Level)
      Bidi::Level.create(1).should be_a(Bidi::Level)
      Bidi::Level.create(10).should be_a(Bidi::Level)
      Bidi::Level.create(125).should be_a(Bidi::Level)
      Bidi::Level.create(126).should be_a(Bidi::Level) # MAX_IMPLICIT_DEPTH
      Bidi::Level.create(127).should eq(Bidi::Level::Error::OutOfRangeNumber)
    end

    it "creates explicit levels" do
      Bidi::Level.create_explicit(0).should be_a(Bidi::Level)
      Bidi::Level.create_explicit(1).should be_a(Bidi::Level)
      Bidi::Level.create_explicit(10).should be_a(Bidi::Level)
      Bidi::Level.create_explicit(125).should be_a(Bidi::Level) # MAX_EXPLICIT_DEPTH
      Bidi::Level.create_explicit(126).should eq(Bidi::Level::Error::OutOfRangeNumber)
    end
  end

  describe "#ltr?" do
    it "returns true for even levels" do
      Bidi::Level.from(0).ltr?.should be_true
      Bidi::Level.from(2).ltr?.should be_true
      Bidi::Level.from(10).ltr?.should be_true
      Bidi::Level.from(124).ltr?.should be_true
    end

    it "returns false for odd levels" do
      Bidi::Level.from(1).ltr?.should be_false
      Bidi::Level.from(3).ltr?.should be_false
      Bidi::Level.from(11).ltr?.should be_false
      Bidi::Level.from(125).ltr?.should be_false
    end
  end

  describe "#rtl?" do
    it "returns true for odd levels" do
      Bidi::Level.from(1).rtl?.should be_true
      Bidi::Level.from(3).rtl?.should be_true
      Bidi::Level.from(11).rtl?.should be_true
      Bidi::Level.from(125).rtl?.should be_true
    end

    it "returns false for even levels" do
      Bidi::Level.from(0).rtl?.should be_false
      Bidi::Level.from(2).rtl?.should be_false
      Bidi::Level.from(10).rtl?.should be_false
      Bidi::Level.from(124).rtl?.should be_false
    end
  end

  describe "#raise" do
    it "increases level by amount" do
      level = Bidi::Level.ltr
      level.number.should eq(0)
      level.raise(100_u8).should be_nil
      level.number.should eq(100)
      level.raise(26_u8).should be_nil
      level.number.should eq(126) # MAX_IMPLICIT_DEPTH
      level.raise(1_u8).should eq(Bidi::Level::Error::OutOfRangeNumber)
      level.number.should eq(126) # unchanged on error
    end
  end

  describe "#raise_explicit" do
    it "increases level by amount within explicit limits" do
      level = Bidi::Level.ltr
      level.number.should eq(0)
      level.raise_explicit(100_u8).should be_nil
      level.number.should eq(100)
      level.raise_explicit(25_u8).should be_nil
      level.number.should eq(125) # MAX_EXPLICIT_DEPTH
      level.raise_explicit(1_u8).should eq(Bidi::Level::Error::OutOfRangeNumber)
      level.number.should eq(125) # unchanged on error
    end
  end

  describe "#lower" do
    it "decreases level by amount" do
      level = Bidi::Level.rtl
      level.number.should eq(1)
      level.lower(1_u8).should be_nil
      level.number.should eq(0)
      level.lower(1_u8).should eq(Bidi::Level::Error::OutOfRangeNumber)
      level.number.should eq(0) # unchanged on error
    end
  end

  describe ".has_rtl?" do
    it "returns true if any level is RTL" do
      Bidi::Level.has_rtl?([Bidi::Level.from(0), Bidi::Level.from(0), Bidi::Level.from(0)]).should be_false
      Bidi::Level.has_rtl?([Bidi::Level.from(0), Bidi::Level.from(1), Bidi::Level.from(0)]).should be_true
      Bidi::Level.has_rtl?([Bidi::Level.from(0), Bidi::Level.from(2), Bidi::Level.from(0)]).should be_false
      Bidi::Level.has_rtl?([Bidi::Level.from(0), Bidi::Level.from(125), Bidi::Level.from(0)]).should be_true
      Bidi::Level.has_rtl?([Bidi::Level.from(0), Bidi::Level.from(126), Bidi::Level.from(0)]).should be_false
    end
  end

  describe ".vec" do
    it "converts array of u8 to array of Levels" do
      levels = Bidi::Level.vec([0_u8, 1_u8, 2_u8, 125_u8])
      levels.size.should eq(4)
      levels[0].number.should eq(0)
      levels[1].number.should eq(1)
      levels[2].number.should eq(2)
      levels[3].number.should eq(125)
    end
  end

  describe "#number" do
    it "returns the level number" do
      Bidi::Level.from(0).number.should eq(0)
      Bidi::Level.from(42).number.should eq(42)
      Bidi::Level.from(125).number.should eq(125)
    end
  end

  describe ".ltr" do
    it "returns LTR level (0)" do
      Bidi::Level.ltr.number.should eq(0)
      Bidi::Level.ltr.ltr?.should be_true
      Bidi::Level.ltr.rtl?.should be_false
    end
  end

  describe ".rtl" do
    it "returns RTL level (1)" do
      Bidi::Level.rtl.number.should eq(1)
      Bidi::Level.rtl.ltr?.should be_false
      Bidi::Level.rtl.rtl?.should be_true
    end
  end

  describe "#bidi_class" do
    it "returns R for RTL levels" do
      Bidi::Level.from(1).bidi_class.should eq(Bidi::BidiClass::R)
      Bidi::Level.from(3).bidi_class.should eq(Bidi::BidiClass::R)
      Bidi::Level.from(125).bidi_class.should eq(Bidi::BidiClass::R)
    end

    it "returns L for LTR levels" do
      Bidi::Level.from(0).bidi_class.should eq(Bidi::BidiClass::L)
      Bidi::Level.from(2).bidi_class.should eq(Bidi::BidiClass::L)
      Bidi::Level.from(124).bidi_class.should eq(Bidi::BidiClass::L)
    end
  end

  describe "#new_explicit_next_ltr" do
    it "returns next LTR level greater than current" do
      Bidi::Level.from(0).new_explicit_next_ltr.should eq(Bidi::Level.from(2))
      Bidi::Level.from(1).new_explicit_next_ltr.should eq(Bidi::Level.from(2))
      Bidi::Level.from(2).new_explicit_next_ltr.should eq(Bidi::Level.from(4))
      Bidi::Level.from(124).new_explicit_next_ltr.should eq(Bidi::Level::Error::OutOfRangeNumber) # 126 > MAX_EXPLICIT_DEPTH
    end
  end

  describe "#new_explicit_next_rtl" do
    it "returns next RTL level greater than current" do
      Bidi::Level.from(0).new_explicit_next_rtl.should eq(Bidi::Level.from(1))
      Bidi::Level.from(1).new_explicit_next_rtl.should eq(Bidi::Level.from(3))
      Bidi::Level.from(2).new_explicit_next_rtl.should eq(Bidi::Level.from(3))
      Bidi::Level.from(124).new_explicit_next_rtl.should eq(Bidi::Level.from(125))
      Bidi::Level.from(125).new_explicit_next_rtl.should eq(Bidi::Level::Error::OutOfRangeNumber) # 127 > MAX_EXPLICIT_DEPTH
    end
  end

  describe "#new_lowest_ge_rtl" do
    it "returns lowest RTL level greater than or equal to current" do
      Bidi::Level.from(0).new_lowest_ge_rtl.should eq(Bidi::Level.from(1))
      Bidi::Level.from(1).new_lowest_ge_rtl.should eq(Bidi::Level.from(1))
      Bidi::Level.from(2).new_lowest_ge_rtl.should eq(Bidi::Level.from(3))
      Bidi::Level.from(124).new_lowest_ge_rtl.should eq(Bidi::Level.from(125))
      Bidi::Level.from(125).new_lowest_ge_rtl.should eq(Bidi::Level.from(125))
      Bidi::Level.from(126).new_lowest_ge_rtl.should eq(Bidi::Level::Error::OutOfRangeNumber) # 127 > MAX_IMPLICIT_DEPTH
    end
  end
end
