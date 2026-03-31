# Performance profiling example
#
# Similar to Rust's flame_udhr.rs example, this shows how to profile
# bidi processing performance. In a real scenario, you would use
# proper profiling tools.

require "../src/bidi"

puts "=== Performance Testing Example ==="

# Load test data (using a simple test string since we don't have the UDHR file)
# In the Rust example, they use: include_str!("../data/udhr/bidi/udhr_pes_1.txt")
test_text = <<-TEXT
This is a test text with mixed directionality.
Hello שלום עולם - this is a mixed English and Hebrew text.
مرحبا بالعالم - this is Arabic greeting.
123 מספרים - numbers with Hebrew.
TEXT

puts "Test text length: #{test_text.bytesize} bytes"
puts "Test text characters: #{test_text.size}"

# Time the analysis
start_time = Time.instant
bidi_info = Bidi::BidiInfo.new(test_text, nil)
analysis_time = Time.instant - start_time

puts "\nAnalysis phase:"
puts "  Time: #{analysis_time.total_milliseconds.round(2)} ms"
puts "  Paragraphs found: #{bidi_info.paragraphs.size}"

# Time the reordering
start_time = Time.instant
total_chars = 0
bidi_info.paragraphs.each do |para|
  line = para.range
  reordered = bidi_info.reorder_line(para, line)
  total_chars += reordered.size
end
reorder_time = Time.instant - start_time

puts "\nReordering phase:"
puts "  Time: #{reorder_time.total_milliseconds.round(2)} ms"
puts "  Total characters processed: #{total_chars}"
puts "  Throughput: #{(total_chars / reorder_time.total_seconds).round} chars/sec"

# Compare with ParagraphBidiInfo (should be faster for single paragraph)
puts "\n=== Comparison: BidiInfo vs ParagraphBidiInfo ==="

# Split text into paragraphs
paragraphs = test_text.split("\n")

paragraphs.each_with_index do |para_text, i|
  next if para_text.empty?

  puts "\nParagraph #{i + 1} (#{para_text.size} chars):"

  # Time BidiInfo
  start_time = Time.instant
  info1 = Bidi::BidiInfo.new(para_text, nil)
  reordered1 = info1.reorder_line(info1.paragraphs[0], info1.paragraphs[0].range)
  time1 = Time.instant - start_time

  # Time ParagraphBidiInfo
  start_time = Time.instant
  info2 = Bidi::ParagraphBidiInfo.new(para_text, nil)
  reordered2 = info2.reorder_line(0...para_text.bytesize)
  time2 = Time.instant - start_time

  puts "  BidiInfo: #{time1.total_microseconds.round(2)} µs"
  puts "  ParagraphBidiInfo: #{time2.total_microseconds.round(2)} µs"
  puts "  Speedup: #{(time1.total_microseconds / time2.total_microseconds).round(2)}x"
  puts "  Results match: #{reordered1 == reordered2}"
end

# Batch processing example
puts "\n=== Batch Processing Example ==="

texts = [
  "Hello World",
  "שלום עולם",
  "مرحبا Hello",
  "Test עם Hebrew",
  "Another test with 123 numbers",
  "Mixed: Hello (שלום) World",
]

# Process individually
individual_times = [] of Float64
individual_results = [] of String

texts.each do |text|
  start_time = Time.instant
  info = Bidi::ParagraphBidiInfo.new(text, nil)
  result = info.reorder_line(0...text.bytesize)
  individual_times << (Time.instant - start_time).total_microseconds
  individual_results << result
end

total_individual_time = individual_times.sum

# Process as batch (simulated - in real app you might use threads)
start_time = Time.instant
batch_results = texts.map do |text|
  info = Bidi::ParagraphBidiInfo.new(text, nil)
  info.reorder_line(0...text.bytesize)
end
batch_time = (Time.instant - start_time).total_microseconds

puts "Individual processing: #{total_individual_time.round(2)} µs total"
puts "Batch processing: #{batch_time.round(2)} µs total"
puts "Batch efficiency: #{(total_individual_time / batch_time).round(2)}x faster"

# Verify all results match
all_match = individual_results.each_with_index.all? do |result, i|
  result == batch_results[i]
end
puts "All results match: #{all_match}"

# Memory usage estimation (simplified)
puts "\n=== Memory Usage Estimation ==="
sample_text = "A" * 1000 + "ש" * 1000  # 2000 characters

# Estimate memory for BidiInfo
info = Bidi::BidiInfo.new(sample_text, nil)
levels_size = info.levels.size * sizeof(Int32)  # Each level is Int32
original_text_size = sample_text.bytesize

puts "Sample text: #{sample_text.size} chars, #{sample_text.bytesize} bytes"
puts "BidiInfo levels array: #{levels_size} bytes"
puts "Total estimated: #{original_text_size + levels_size} bytes"
puts "Overhead: #{((levels_size.to_f / original_text_size) * 100).round(2)}%"