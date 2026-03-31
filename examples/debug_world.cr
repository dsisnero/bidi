#!/usr/bin/env crystal
require "../src/bidi"

text = "Hello שלום World"
puts "Text: #{text.inspect}"
puts "Bytes: #{text.bytes.map(&.to_s(16)).join(' ')}"

bidi_info = Bidi::BidiInfo.new(text, nil)
para = bidi_info.paragraphs[0]
line = para.range

levels, runs = bidi_info.visual_runs(para, line)
puts "\nVisual runs:"
runs.each_with_index do |run, i|
  level = levels[run.begin]?
  run_text = text.byte_slice(run.begin, run.end - run.begin)
  puts "  Run #{i}: #{run} (level: #{level}, text: #{run_text.inspect})"
end

puts "\nLevels:"
levels.each_with_index do |level, i|
  puts "  #{i}: #{level}" if i < text.bytesize
end

# Manually check what should happen
puts "\nAnalysis:"
puts "  'Hello ' (bytes 0-6): LTR in LTR paragraph = level 0"
puts "  'שלום' (bytes 7-14): RTL in LTR paragraph = level 1"
puts "  ' World' (bytes 15-21): LTR in LTR paragraph = level 0"
puts "  But 'World' is split: 'W' at byte 15, 'orld' at bytes 16-21"
puts "  'W' might be getting level 2? Let's check..."