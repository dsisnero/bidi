# Script to convert Rust bidi_class_table to Crystal format

input = File.read("/tmp/rust_bidi_table.txt")
lines = input.lines

# Skip first line (pub const bidi_class_table: &'static [(char, char, BidiClass)] = &[)
# and last line (];)
table_lines = lines[1...-1]

output = [] of String
output << "BIDI_CLASS_TABLE = ["

# Process all lines together to handle multi-line entries
full_text = table_lines.join(" ")
# Split by ), ( to get individual entries
entries = full_text.split(/\),\s*\(/)

entries.each_with_index do |entry, i|
  entry = entry.strip
  next if entry.empty?

  # Remove leading/trailing parentheses if present
  entry = entry.sub(/^\(/, "").sub(/\)$/, "")

  # Split by comma
  parts = entry.split(",").map(&.strip)
  next if parts.size < 3

  # Extract values
  lo = parts[0]
  hi = parts[1]
  bidi_class = parts[2]

  # Handle multi-line hi value (like '\u{23}', '\u{25}', ET)
  if hi.includes?("'") && hi.count("'") == 1
    # hi is split across lines, need to get next part
    if parts.size >= 4
      bidi_class = parts[3]
    end
  end

  # Clean up quotes
  lo = lo.gsub("'", "'")
  hi = hi.gsub("'", "'")

  # Add BidiClass:: prefix
  bidi_class = "BidiClass::#{bidi_class}"

  output << "  {#{lo}, #{hi}, #{bidi_class}},"
end

output << "]"

File.write("/tmp/crystal_bidi_table.txt", output.join("\n"))
puts "Converted table written to /tmp/crystal_bidi_table.txt"
puts "Entries: #{entries.size}"
puts "Output lines: #{output.size}"
