#!/usr/bin/env crystal
require "../src/bidi"

# Test case from Rust documentation
text = "אבגabc"
puts "Test 1: #{text.inspect}"
bidi_info = Bidi::BidiInfo.new(text, nil)
para = bidi_info.paragraphs[0]
line = para.range
display = bidi_info.reorder_line(para, line)
puts "  Expected: \"abcגבא\" (abc not reversed + אבג reversed)"
puts "  Got: #{display.inspect}"
puts "  Correct? #{display == "abcגבא"}"

# Test with explicit paragraph level
puts "\nTest 2: #{text.inspect} with LTR paragraph level"
bidi_info2 = Bidi::BidiInfo.new(text, Bidi::Level.ltr)
para2 = bidi_info2.paragraphs[0]
display2 = bidi_info2.reorder_line(para2, para2.range)
puts "  Got: #{display2.inspect}"

# Test mixed text
text3 = "Hello שלום World"
puts "\nTest 3: #{text3.inspect}"
bidi_info3 = Bidi::BidiInfo.new(text3, nil)
para3 = bidi_info3.paragraphs[0]
display3 = bidi_info3.reorder_line(para3, para3.range)
puts "  Got: #{display3.inspect}"

# Test all LTR
text4 = "Hello World"
puts "\nTest 4: #{text4.inspect}"
bidi_info4 = Bidi::BidiInfo.new(text4, nil)
para4 = bidi_info4.paragraphs[0]
display4 = bidi_info4.reorder_line(para4, para4.range)
puts "  Got: #{display4.inspect}"
puts "  Same as original? #{display4 == text4}"

# Test all RTL
text5 = "שלום עולם"
puts "\nTest 5: #{text5.inspect}"
bidi_info5 = Bidi::BidiInfo.new(text5, nil)
para5 = bidi_info5.paragraphs[0]
display5 = bidi_info5.reorder_line(para5, para5.range)
puts "  Got: #{display5.inspect}"
puts "  Same as original? #{display5 == text5}"