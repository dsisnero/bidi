# bidi Examples

Comprehensive examples showing how to use the bidi library for Unicode Bidirectional Algorithm processing.

## Basic Usage

### Simple Text Analysis

```crystal
require "bidi"

# Analyze mixed-direction text
text = "Hello שלום"  # "Hello" (LTR) + "Shalom" (RTL)
info = Bidi::BidiInfo.new(text, nil)

# Get paragraph information
para = info.paragraphs[0]
puts "Paragraph range: #{para.range}"
puts "Paragraph level: #{para.level}"
puts "Paragraph direction: #{para.direction}"

# Reorder for display
reordered = info.reorder_line(para, para.range)
puts "Original: #{text}"
puts "Reordered: #{reordered}"  # "Hello םולש"
```

### Single Paragraph API

```crystal
require "bidi"

# Simpler API for single-paragraph text
text = "مرحبا Hello"  # Arabic "Hello" + English "Hello"
info = Bidi::ParagraphBidiInfo.new(text, nil)

# Reorder the entire line
reordered = info.reorder_line(0...text.bytesize)
puts "Original: #{text}"
puts "Reordered: #{reordered}"  # "Hello مرحبا"
```

## Advanced Examples

### Working with Embedding Levels

```crystal
require "bidi"

text = "A B C [RTL D E F] G H I"
info = Bidi::BidiInfo.new(text, nil)

# Get embedding levels for each character
levels = info.levels
text.each_char_with_index do |char, i|
  level = info.level_at(i)
  puts "Character '#{char}' at position #{i}: level #{level.value} (#{level.rtl? ? 'RTL' : 'LTR'})"
end

# Get visual runs (contiguous segments with same level)
para = info.paragraphs[0]
runs = info.visual_runs(para, para.range)
runs.each do |run|
  segment = text[run]
  puts "Run level #{info.level_at(run.begin).value}: '#{segment}'"
end
```

### UTF-16 Text Processing

```crystal
require "bidi"

# UTF-16 text (Array(UInt16))
text = "abcאבג"  # "abc" (LTR) + Hebrew "ABC" (RTL)
utf16_text = text.codepoints.map(&.to_u16)

# Analyze UTF-16 text
info = Bidi::UTF16::BidiInfo.new(utf16_text, nil)
para = info.paragraphs[0]

# Reorder returns Array(UInt16)
reordered_utf16 = info.reorder_line(para, 0...utf16_text.size)

# Convert back to string
reordered_string = String.from_utf16(reordered_utf16)
puts "Original: #{text}"
puts "Reordered: #{reordered_string}"  # "abcגבא"
```

### Direction Detection

```crystal
require "bidi"

# Determine base direction of text
samples = [
  "Hello World",           # LTR
  "שלום עולם",             # RTL  
  "123",                   # Mixed (neutral)
  "Hello 123",             # LTR (first strong character is LTR)
  "مرحبا 123",             # RTL (first strong character is RTL)
  "",                      # LTR (empty string)
  " ",                     # LTR (only neutral characters)
  "Hello (שלום) World",    # Mixed
]

samples.each do |text|
  direction = Bidi.get_base_direction(text)
  puts "'#{text}' => #{direction}"
end
```

## Real-World Scenarios

### Displaying Mixed-Content UI

```crystal
require "bidi"

# Simulate a UI with mixed LTR/RTL content
ui_texts = [
  "Welcome: שלום",           # Welcome message with Hebrew greeting
  "Price: 100₪",             # Price with currency symbol
  "Error: שגיאה במערכת",     # Error message in Hebrew
  "Status: פעיל",            # Status indicator
]

ui_texts.each do |text|
  info = Bidi::ParagraphBidiInfo.new(text, nil)
  reordered = info.reorder_line(0...text.bytesize)
  
  puts "UI Display:"
  puts "  Original:  #{text}"
  puts "  Reordered: #{reordered}"
  puts "  Direction: #{Bidi.get_base_direction(text)}"
  puts
end
```

### Processing User Input

```crystal
require "bidi"

# Process user input with potential RTL content
def process_user_input(input : String)
  # Determine if input contains RTL content
  direction = Bidi.get_base_direction(input)
  
  case direction
  when Bidi::Direction::Ltr
    puts "Input is primarily LTR: #{input}"
  when Bidi::Direction::Rtl
    puts "Input is primarily RTL: #{input}"
    
    # Reorder for proper display
    info = Bidi::ParagraphBidiInfo.new(input, nil)
    reordered = info.reorder_line(0...input.bytesize)
    puts "Display as: #{reordered}"
  when Bidi::Direction::Mixed
    puts "Input has mixed direction: #{input}"
    
    # Analyze and reorder mixed content
    info = Bidi::BidiInfo.new(input, nil)
    para = info.paragraphs[0]
    reordered = info.reorder_line(para, para.range)
    puts "Display as: #{reordered}"
  end
end

# Test with various inputs
process_user_input("Hello World")
process_user_input("שלום עולם")
process_user_input("Hello (שלום) World")
```

### Text Layout for PDF/Print

```crystal
require "bidi"

# Prepare text for PDF layout with proper bidi support
def prepare_text_for_layout(text : String, width : Int32) : Array(String)
  lines = [] of String
  current_line = ""
  
  info = Bidi::BidiInfo.new(text, nil)
  para = info.paragraphs[0]
  
  # Simple word wrapping (in real implementation, use proper text layout)
  words = text.split(' ')
  
  words.each do |word|
    if (current_line + " " + word).size > width
      # Reorder current line before adding to output
      line_info = Bidi::ParagraphBidiInfo.new(current_line, nil)
      reordered = line_info.reorder_line(0...current_line.bytesize)
      lines << reordered
      current_line = word
    else
      current_line += " " + word unless current_line.empty?
      current_line += word if current_line.empty?
    end
  end
  
  # Add last line
  unless current_line.empty?
    line_info = Bidi::ParagraphBidiInfo.new(current_line, nil)
    reordered = line_info.reorder_line(0...current_line.bytesize)
    lines << reordered
  end
  
  lines
end

# Example usage
text = "This is a test עם טקסט בעברית mixed with English text"
lines = prepare_text_for_layout(text, 20)
lines.each_with_index do |line, i|
  puts "Line #{i + 1}: #{line}"
end
```

## Performance Considerations

### Batch Processing

```crystal
require "bidi"

# Process multiple texts efficiently
texts = [
  "Hello World",
  "שלום עולם",
  "مرحبا Hello",
  "Test עם Hebrew",
  "Another test",
]

# Pre-allocate reusable analyzer for similar texts
def analyze_batch(texts : Array(String))
  results = [] of Tuple(String, Bidi::Direction, String)
  
  texts.each do |text|
    # Use ParagraphBidiInfo for single-paragraph texts (faster)
    info = Bidi::ParagraphBidiInfo.new(text, nil)
    direction = Bidi.get_base_direction(text)
    reordered = info.reorder_line(0...text.bytesize)
    
    results << {text, direction, reordered}
  end
  
  results
end

# Process batch
results = analyze_batch(texts)
results.each do |original, direction, reordered|
  puts "#{direction}: #{original} -> #{reordered}"
end
```

## Testing Your Implementation

### Verifying Bidi Behavior

```crystal
require "bidi"

# Test suite for bidi functionality
def test_bidi_functionality
  test_cases = [
    {
      input: "Hello",
      expected_direction: Bidi::Direction::Ltr,
      expected_reordered: "Hello"
    },
    {
      input: "שלום",
      expected_direction: Bidi::Direction::Rtl,
      expected_reordered: "םולש"
    },
    {
      input: "Hello שלום",
      expected_direction: Bidi::Direction::Mixed,
      expected_reordered: "Hello םולש"
    },
    {
      input: "",
      expected_direction: Bidi::Direction::Ltr,
      expected_reordered: ""
    }
  ]
  
  test_cases.each_with_index do |test_case, i|
    input = test_case[:input]
    expected_direction = test_case[:expected_direction]
    expected_reordered = test_case[:expected_reordered]
    
    # Test direction detection
    actual_direction = Bidi.get_base_direction(input)
    
    # Test reordering
    info = Bidi::ParagraphBidiInfo.new(input, nil)
    actual_reordered = info.reorder_line(0...input.bytesize)
    
    direction_ok = actual_direction == expected_direction
    reorder_ok = actual_reordered == expected_reordered
    
    puts "Test #{i + 1}: #{direction_ok && reorder_ok ? 'PASS' : 'FAIL'}"
    puts "  Input: '#{input}'"
    puts "  Direction: expected #{expected_direction}, got #{actual_direction}" unless direction_ok
    puts "  Reordered: expected '#{expected_reordered}', got '#{actual_reordered}'" unless reorder_ok
    puts
  end
end

# Run tests
test_bidi_functionality
```

## Integration Examples

### With Web Framework (Kemal, Lucky, etc.)

```crystal
# Example with Kemal web framework
require "kemal"
require "bidi"

# Middleware to handle RTL text in responses
class BidiMiddleware
  include HTTP::Handler
  
  def call(context)
    call_next(context)
    
    # Check if response contains text that might need bidi processing
    content_type = context.response.headers["Content-Type"]?
    if content_type && content_type.includes?("text/html")
      # In a real implementation, you would parse HTML and process text nodes
      # This is a simplified example
      puts "HTML response might contain RTL text"
    end
  end
end

# Add middleware
add_handler BidiMiddleware.new

# API endpoint that returns text with proper bidi handling
get "/api/text/:input" do |env|
  input = env.params.url["input"]
  
  # Analyze and reorder text
  info = Bidi::ParagraphBidiInfo.new(input, nil)
  reordered = info.reorder_line(0...input.bytesize)
  direction = Bidi.get_base_direction(input)
  
  {
    original: input,
    reordered: reordered,
    direction: direction.to_s,
    visual_runs: info.visual_runs(0...input.bytesize).map do |run|
      {
        range: {run.begin, run.end},
        level: info.level_at(run.begin).value,
        text: input[run]
      }
    end
  }.to_json
end

Kemal.run
```

### With Database Storage

```crystal
require "bidi"

# When storing text in a database, you might want to store both
# the original and the display-ready version
class Message
  property id : Int32
  property content : String
  property content_display : String
  property direction : String
  
  def initialize(@id, @content)
    # Process for display
    info = Bidi::ParagraphBidiInfo.new(@content, nil)
    @content_display = info.reorder_line(0...@content.bytesize)
    @direction = Bidi.get_base_direction(@content).to_s
  end
  
  def to_json(json : JSON::Builder)
    json.object do
      json.field "id", @id
      json.field "content", @content
      json.field "content_display", @content_display
      json.field "direction", @direction
    end
  end
end

# Example usage
messages = [
  Message.new(1, "Hello World"),
  Message.new(2, "שלום עולם"),
  Message.new(3, "مرحبا Hello"),
]

messages.each do |msg|
  puts msg.to_json
end
```

## Troubleshooting

### Common Issues and Solutions

1. **Text not reordering correctly**
   - Ensure you're using the correct API (`BidiInfo` for multi-paragraph, `ParagraphBidiInfo` for single)
   - Check that text encoding is UTF-8
   - Verify that the text actually contains RTL characters

2. **Performance issues with large texts**
   - Use `ParagraphBidiInfo` instead of `BidiInfo` for single-paragraph texts
   - Cache results if processing the same text multiple times
   - Consider batch processing for multiple texts

3. **UTF-16 issues**
   - Ensure proper surrogate pair handling when converting to/from UTF-16
   - Use `Bidi::UTF16::BidiInfo` for UTF-16 text
   - Remember that `reorder_line` returns `Array(UInt16)` for UTF-16

4. **Empty string handling**
   - `get_base_direction("")` returns `Ltr` (matching Rust behavior)
   - `reorder_line` on empty string returns empty string

## Next Steps

- Explore the [API Reference](../api/index.html) for complete documentation
- Check [Architecture Guide](architecture.md) for implementation details
- Run the [test suite](../../README.md#testing) to verify functionality
- Review [Unicode Technical Report #9](https://www.unicode.org/reports/tr9/) for algorithm details