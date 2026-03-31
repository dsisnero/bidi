#!/usr/bin/env crystal
require "../src/bidi"

text = "שלום hello world"
puts "Text: #{text.inspect}"
puts "Bytes: #{text.bytes.map(&.to_s(16)).join(' ')}"
puts "Characters:"
text.each_char_with_index do |char, i|
  puts "  #{i}: #{char.inspect} (U+#{char.ord.to_s(16).upcase}, bytes: #{char.bytes.map(&.to_s(16)).join(' ')})"
end

bidi_info = Bidi::BidiInfo.new(text, nil)
para = bidi_info.paragraphs[0]
line = para.range

levels, runs = bidi_info.visual_runs(para, line)
puts "\nVisual runs:"
runs.each_with_index do |run, i|
  level = levels[run.begin]?
  text_segment = text[run]
  puts "  Run #{i}: #{run} (level: #{level}, text: #{text_segment.inspect})"
  puts "    Bytes in run: #{run.to_a.map { |j| text.byte_at(j).to_s(16) }.join(' ')}"
end

puts "\nLevels array:"
levels.each_with_index do |level, i|
  puts "  #{i}: #{level}" if i < text.bytesize
end