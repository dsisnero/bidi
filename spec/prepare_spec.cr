require "./spec_helper"

describe Bidi do
  describe ".level_runs" do
    it "returns empty array for empty input" do
      Bidi.level_runs([] of Bidi::Level, [] of Bidi::BidiClass).should eq([] of Bidi::LevelRun)
    end

    it "finds level runs" do
      levels = Bidi::Level.vec([0_u8, 0_u8, 0_u8, 1_u8, 1_u8, 2_u8, 0_u8, 0_u8])
      classes = [Bidi::BidiClass::L] * 8
      runs = Bidi.level_runs(levels, classes)
      runs.should eq([0...3, 3...5, 5...6, 6...8])
    end
  end

  describe ".removed_by_x9" do
    it "returns true for characters removed by X9" do
      Bidi.removed_by_x9(Bidi::BidiClass::RLE).should be_true
      Bidi.removed_by_x9(Bidi::BidiClass::LRE).should be_true
      Bidi.removed_by_x9(Bidi::BidiClass::RLO).should be_true
      Bidi.removed_by_x9(Bidi::BidiClass::LRO).should be_true
      Bidi.removed_by_x9(Bidi::BidiClass::PDF).should be_true
      Bidi.removed_by_x9(Bidi::BidiClass::BN).should be_true
    end

    it "returns false for characters not removed by X9" do
      Bidi.removed_by_x9(Bidi::BidiClass::L).should be_false
      Bidi.removed_by_x9(Bidi::BidiClass::R).should be_false
      Bidi.removed_by_x9(Bidi::BidiClass::EN).should be_false
    end
  end

  describe ".isolating_run_sequences" do
    it "handles example 1 from Unicode TR9 BD13" do
      # text1·RLE·text2·PDF·RLE·text3·PDF·text4
      # index        0    1  2    3    4  5    6  7
      classes = [
        Bidi::BidiClass::L,
        Bidi::BidiClass::RLE,
        Bidi::BidiClass::L,
        Bidi::BidiClass::PDF,
        Bidi::BidiClass::RLE,
        Bidi::BidiClass::L,
        Bidi::BidiClass::PDF,
        Bidi::BidiClass::L,
      ]
      levels = Bidi::Level.vec([0_u8, 1_u8, 1_u8, 1_u8, 1_u8, 1_u8, 1_u8, 0_u8])
      para_level = Bidi::Level.ltr
      runs = Bidi.level_runs(levels, classes)

      sequences = [] of Bidi::IsolatingRunSequence
      Bidi.isolating_run_sequences(
        para_level,
        classes,
        levels,
        runs,
        false, # has_isolate_controls
        sequences
      )

      # Sort by first run start for comparison
      sequences.sort_by!(&.runs[0].begin)

      sequences.size.should eq(3)
      sequences[0].runs.should eq([0...2])
      sequences[1].runs.should eq([2...7])
      sequences[2].runs.should eq([7...8])
    end

    it "handles example 2 from Unicode TR9 BD13" do
      # text1·RLI·text2·PDI·RLI·text3·PDI·text4
      # index        0    1  2    3    4  5    6  7
      classes = [
        Bidi::BidiClass::L,
        Bidi::BidiClass::RLI,
        Bidi::BidiClass::L,
        Bidi::BidiClass::PDI,
        Bidi::BidiClass::RLI,
        Bidi::BidiClass::L,
        Bidi::BidiClass::PDI,
        Bidi::BidiClass::L,
      ]
      levels = Bidi::Level.vec([0_u8, 0_u8, 1_u8, 0_u8, 0_u8, 1_u8, 0_u8, 0_u8])
      para_level = Bidi::Level.ltr
      runs = Bidi.level_runs(levels, classes)

      sequences = [] of Bidi::IsolatingRunSequence
      Bidi.isolating_run_sequences(
        para_level,
        classes,
        levels,
        runs,
        true, # has_isolate_controls
        sequences
      )

      # Sort by first run start for comparison
      sequences.sort_by!(&.runs[0].begin)

      sequences.size.should eq(3)
      sequences[0].runs.should eq([0...2, 3...5, 6...8])
      sequences[1].runs.should eq([2...3])
      sequences[2].runs.should eq([5...6])
    end

    # Test SOS and EOS values per X10 examples
    it "verifies sos and eos values for example 1" do
      # text1·RLE·text2·LRE·text3·PDF·text4·PDF·RLE·text5·PDF·text6
      # index        0    1  2    3  4    5  6    7    8  9   10  11
      classes = [
        Bidi::BidiClass::L, Bidi::BidiClass::RLE, Bidi::BidiClass::L,
        Bidi::BidiClass::LRE, Bidi::BidiClass::L, Bidi::BidiClass::PDF,
        Bidi::BidiClass::L, Bidi::BidiClass::PDF, Bidi::BidiClass::RLE,
        Bidi::BidiClass::L, Bidi::BidiClass::PDF, Bidi::BidiClass::L,
      ]
      levels = Bidi::Level.vec([0_u8, 1_u8, 1_u8, 2_u8, 2_u8, 2_u8, 1_u8, 1_u8, 1_u8, 1_u8, 1_u8, 0_u8])
      para_level = Bidi::Level.ltr
      runs = Bidi.level_runs(levels, classes)

      sequences = [] of Bidi::IsolatingRunSequence
      Bidi.isolating_run_sequences(para_level, classes, levels, runs, false, sequences)
      sequences.sort_by!(&.runs[0].begin)

      sequences.size.should eq 5
      # text1
      sequences[0].sos.should eq Bidi::BidiClass::L
      sequences[0].eos.should eq Bidi::BidiClass::R
      # text2
      sequences[1].sos.should eq Bidi::BidiClass::R
      sequences[1].eos.should eq Bidi::BidiClass::L
      # text3
      sequences[2].sos.should eq Bidi::BidiClass::L
      sequences[2].eos.should eq Bidi::BidiClass::L
      # text4 text5
      sequences[3].sos.should eq Bidi::BidiClass::L
      sequences[3].eos.should eq Bidi::BidiClass::R
      # text6
      sequences[4].sos.should eq Bidi::BidiClass::R
      sequences[4].eos.should eq Bidi::BidiClass::L
    end
  end
end
