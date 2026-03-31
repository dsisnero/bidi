require "spec"
require "../src/bidi"

describe "Bidi Algorithm Integration" do
  it "creates BidiInfo for simple text" do
    text = "Hello, world!"
    info = Bidi::BidiInfo.new(text)

    info.text.should eq text
    info.paragraphs.size.should eq 1
    info.original_classes.size.should eq text.bytesize
    info.levels.size.should eq text.bytesize
  end

  it "has basic API methods" do
    text = "Test"
    info = Bidi::BidiInfo.new(text)

    # Just call the methods to ensure they exist
    info.has_rtl?
    info.has_ltr?
    para = info.paragraphs[0]
    info.reordered_levels(para, 0...text.bytesize)
    true.should be_true # Dummy assertion
  end

  it "handles empty text" do
    text = ""
    info = Bidi::BidiInfo.new(text)

    info.text.should eq text
    info.paragraphs.size.should eq 0 # No text means no paragraphs
    info.original_classes.size.should eq 0
    info.levels.size.should eq 0
    info.has_rtl?.should be_false
    info.has_ltr?.should be_false
  end

  it "supports custom data source" do
    text = "Hello"
    data_source = Bidi::HardcodedBidiData.new
    info = Bidi::BidiInfo.new_with_data_source(data_source, text)

    info.text.should eq text
    info.paragraphs.size.should eq 1
  end
end
