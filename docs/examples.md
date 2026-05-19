# Examples

## Basic Usage

### Reorder Mixed-Direction Text

```crystal
require "bidi"

text = "Hello שלום"
info = Bidi::BidiInfo.new(text, nil)

para = info.paragraphs[0]
reordered = info.reorder_line(para, para.range)
puts reordered  # "Hello םולש"
```

### Single Paragraph API

```crystal
require "bidi"

text = "مرحبا Hello"
info = Bidi::ParagraphBidiInfo.new(text, nil)
reordered = info.reorder_line(0...text.bytesize)
puts reordered  # "Hello مرحبا"
```

### Base Direction Detection

```crystal
require "bidi"

puts Bidi.get_base_direction("Hello")      # Ltr
puts Bidi.get_base_direction("שלום")       # Rtl
puts Bidi.get_base_direction("123")        # Mixed (all-neutral)
puts Bidi.get_base_direction("Hello 123")  # Ltr (first strong char is L)
puts Bidi.get_base_direction("")           # Mixed (empty)
```

## Working with Levels

```crystal
require "bidi"

text = "abc אבג"
info = Bidi::BidiInfo.new(text, nil)
para = info.paragraphs[0]

# Get per-character levels
levels = info.reordered_levels_per_char(para, para.range)
levels.each_with_index do |level, i|
  puts "Char #{i}: level #{level.number} (#{level.rtl? ? "RTL" : "LTR"})"
end

# Get visual runs
lvs, runs = info.visual_runs(para, para.range)
runs.each do |run|
  segment = text.byte_slice(run.begin, run.end - run.begin)
  puts "Run #{run}: '#{segment}'"
end
```

## UTF-16 Support

```crystal
require "bidi"

text = "abcאבג"
utf16 = text.codepoints.map(&.to_u16)

info = Bidi::UTF16::BidiInfo.new(utf16, nil)
para = info.paragraphs[0]
reordered = info.reorder_line(para, 0...utf16.size)
# reordered is Array(UInt16) in visual order
```

## Manual Visual Reordering

```crystal
require "bidi"

text = "abcאבג"
info = Bidi::BidiInfo.new(text, nil)
para = info.paragraphs[0]

# Get reordered levels
levels = info.reordered_levels_per_char(para, para.range)

# Apply L2 (visual reordering) manually
index_map = Bidi::BidiInfo.reorder_visual(levels)
# index_map[visual_position] = logical_position

visual = String.build(text.bytesize) do |s|
  index_map.each do |logical_idx|
    s << text[logical_idx]
  end
end
```

## Real-World Scenarios

### Processing User Input

```crystal
require "bidi"

def display_text(input : String)
  direction = Bidi.get_base_direction(input)
  info = Bidi::ParagraphBidiInfo.new(input, nil)
  reordered = info.reorder_line(0...input.bytesize)

  puts "Input: #{input}"
  puts "Display: #{reordered}"
  puts "Direction: #{direction}"
end

display_text("Hello שלום World")
```

### Batch Processing

```crystal
require "bidi"

texts = ["Hello World", "שלום עולם", "مرحبا Hello"]

texts.each do |text|
  info = Bidi::ParagraphBidiInfo.new(text, nil)
  reordered = info.reorder_line(0...text.bytesize)
  puts "#{Bidi.get_base_direction(text)}: #{text} → #{reordered}"
end
```

## See Also

- [Architecture](architecture.md) — pipeline details and type mappings
- [Testing](testing.md) — test suite layout and running subsets
- [Parity Tracker](../plans/parity.md) — feature checklist
- [UAX #9](https://www.unicode.org/reports/tr9/) — Unicode Bidirectional Algorithm spec
