# bidi Documentation

Crystal port of Rust `unicode-bidi` crate - Unicode Bidirectional Algorithm implementation

## Documentation Sections

### 📚 Guides
- [Architecture](architecture.md) - System design and implementation details
- [Development](development.md) - Setup and development workflow
- [Coding Guidelines](coding-guidelines.md) - Code style and conventions
- [Testing](testing.md) - Test commands and patterns
- [PR Workflow](pr-workflow.md) - Contribution guidelines

### 🔧 API Reference
- [Full API Documentation](api/index.html) - Complete API reference (generated from source)

### 🚀 Quick Start

```bash
# Add to your shard.yml
dependencies:
  bidi:
    github: dsisnero/bidi
    version: ~> 0.1.0
```

```crystal
require "bidi"

# Analyze mixed-direction text
text = "Hello שלום"  # "Hello" (LTR) + "Shalom" (RTL)
info = Bidi::BidiInfo.new(text, nil)

# Reorder for display
para = info.paragraphs[0]
reordered = info.reorder_line(para, para.range)
puts reordered  # "Hello םולש"
```

## What is bidi?

bidi is a Crystal implementation of the Unicode Bidirectional Algorithm (UBA) as defined in [Unicode Technical Report #9](https://www.unicode.org/reports/tr9/). It provides:

- **Text analysis**: Determine embedding levels and directionality
- **Visual reordering**: Reorder text for proper display
- **UTF-8 and UTF-16 support**: Handle both text encodings
- **Rust parity**: Behavior-identical to Rust `unicode-bidi` v0.3.18

## Key Features

- ✅ **Complete API parity** with Rust `unicode-bidi` crate
- ✅ **UTF-8 and UTF-16 support** with proper surrogate pair handling
- ✅ **Comprehensive testing** (86 original tests + 19 Rust API tests)
- ✅ **Production-ready** with proper error handling
- ✅ **Well-documented** with inline documentation

## Examples

### Basic Usage
```crystal
require "bidi"

# Single paragraph API (simpler)
text = "مرحبا Hello"  # Arabic "Hello" + English "Hello"
info = Bidi::ParagraphBidiInfo.new(text, nil)
reordered = info.reorder_line(0...text.bytesize)
puts reordered  # "Hello مرحبا"
```

### UTF-16 Support
```crystal
require "bidi"

# UTF-16 text (Array(UInt16))
text = "abcאבג"
utf16_text = text.codepoints.map(&.to_u16)

info = Bidi::UTF16::BidiInfo.new(utf16_text, nil)
para = info.paragraphs[0]
reordered = info.reorder_line(para, 0...utf16_text.size)
# Returns Array(UInt16) in visual order
```

### Direction Detection
```crystal
require "bidi"

puts Bidi.get_base_direction("Hello")      # => Ltr
puts Bidi.get_base_direction("שלום")       # => Rtl
puts Bidi.get_base_direction("123")        # => Mixed
puts Bidi.get_base_direction("Hello 123")  # => Ltr
```

## Testing

```bash
# Run all tests
make test

# Run Rust API compatibility tests
crystal spec spec/rust_api_spec.cr

# Generate API documentation
crystal docs --project-name="bidi" --project-version="0.1.0" --output=./docs/api
```

## Contributing

See [PR Workflow](pr-workflow.md) for contribution guidelines.

## License

MIT - See [LICENSE](https://github.com/dsisnero/bidi/blob/main/LICENSE) file.