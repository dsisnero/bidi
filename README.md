<p align="center">
  <strong>Crystal port of Rust unicode-bidi crate</strong><br>
  Unicode Bidirectional Algorithm implementation for mixed RTL/LTR text display
</p>

<p align="center">
  <a href="docs/">Documentation</a> &middot;
  <a href="docs/api/">API Reference</a> &middot;
  <a href="docs/architecture.md">Architecture</a> &middot;
  <a href="docs/development.md">Development</a>
</p>

<p align="center">
  <a href="https://github.com/dsisnero/bidi/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/dsisnero/bidi/ci.yml?style=flat-square" alt="Build Status">
  </a>
  <a href="https://github.com/dsisnero/bidi/releases">
    <img src="https://img.shields.io/github/v/release/dsisnero/bidi?style=flat-square" alt="Release">
  </a>
  <a href="https://github.com/dsisnero/bidi/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/dsisnero/bidi?style=flat-square" alt="License">
  </a>
  <a href="https://github.com/dsisnero/bidi">
    <img src="https://img.shields.io/github/stars/dsisnero/bidi?style=flat-square" alt="Stars">
  </a>
</p>

---

Acts as a translator ensuring right-to-left and left-to-right scripts coexist harmoniously on screen, implementing the Unicode Bidirectional Algorithm to properly display mixed-direction text.

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/dsisnero/bidi.git
cd bidi

# Initialize submodules
git submodule update --init

# Install dependencies
make install

# Run tests
make test

# Run Rust API compatibility tests
crystal spec spec/rust_api_spec.cr
```

## Example Usage

```crystal
require "bidi"

# Basic text analysis
text = "Hello שלום"  # Mixed LTR/RTL text
info = Bidi::BidiInfo.new(text, nil)

# Get paragraph information
para = info.paragraphs[0]
puts "Paragraph level: #{para.level}"  # LTR or RTL

# Reorder line for display
line = para.range
reordered = info.reorder_line(para, line)
puts "Display order: #{reordered}"  # "Hello םולש"

# Single paragraph API (simpler)
para_info = Bidi::ParagraphBidiInfo.new(text, nil)
reordered = para_info.reorder_line(0...text.bytesize)
puts "Display order: #{reordered}"  # "Hello םולש"

# UTF-16 support
utf16_text = text.codepoints.map(&.to_u16)
utf16_info = Bidi::UTF16::BidiInfo.new(utf16_text, nil)
reordered_utf16 = utf16_info.reorder_line(utf16_info.paragraphs[0], 0...utf16_text.size)
# Returns Array(UInt16) in visual order
```

## Features

- **Unicode Bidirectional Algorithm**: Full implementation of UBA as defined in Unicode Technical Report #9
- **Rust parity**: Behavior-identical port of the Rust `unicode-bidi` crate v0.3.18
- **Complete API Coverage**: All public APIs from Rust crate implemented with exact behavioral parity
- **UTF-8 and UTF-16 Support**: Full support for both UTF-8 (`String`) and UTF-16 (`Array(UInt16)`) text
- **Crystal-native API**: Clean Crystal interface with proper type mappings
- **Comprehensive testing**: 86 original tests + 19 Rust API compatibility tests (18 passing, 1 pending)
- **Inventory tracking**: Systematic parity tracking with manifest files

## Development

```bash
make install    # Install dependencies
make update     # Update dependencies
make format     # Format code
make lint       # Lint code (format check + ameba)
make test       # Run tests
make clean      # Clean build artifacts
```

See [Development Guide](docs/development.md) for full setup instructions.

## Documentation

Complete documentation is available at [https://dsisnero.github.io/bidi/](https://dsisnero.github.io/bidi/)

### Quick Links
- [📚 Full Documentation](docs/) - Guides and tutorials
- [🔧 API Reference](docs/api/) - Complete API documentation
- [🏗️ Architecture](docs/architecture.md) - System design and implementation
- [⚙️ Development](docs/development.md) - Setup and workflow
- [🧪 Testing](docs/testing.md) - Test commands and patterns
- [🤝 Contributing](docs/pr-workflow.md) - Contribution guidelines

## Contributing

1. Create an issue: `/forge-create-issue`
2. Implement: `/forge-implement-issue <number>`
3. Self-review: `/forge-reflect-pr`
4. Address feedback: `/forge-address-pr-feedback`
5. Update changelog: `/forge-update-changelog`

## Status

✅ **Complete**: All public APIs from Rust `unicode-bidi` v0.3.18 are implemented with behavioral parity

### API Coverage

| Rust API | Crystal Implementation | Status |
|----------|----------------------|--------|
| `BidiInfo` | `Bidi::BidiInfo` | ✅ Complete |
| `ParagraphBidiInfo` | `Bidi::ParagraphBidiInfo` | ✅ Complete |
| `UTF16::BidiInfo` | `Bidi::UTF16::BidiInfo` | ✅ Complete |
| `UTF16::ParagraphBidiInfo` | `Bidi::UTF16::ParagraphBidiInfo` | ✅ Complete |
| `Level` | `Bidi::Level` | ✅ Complete |
| `BidiClass` | `Bidi::BidiClass` | ✅ Complete |
| `Direction` | `Bidi::Direction` | ✅ Complete |
| `get_base_direction` | `Bidi.get_base_direction` | ✅ Complete |
| `reorder_visual` | `Bidi::BidiInfo.reorder_visual` | ✅ Complete |

### Test Status
- **Original Tests**: 86/86 passing
- **Rust API Compatibility Tests**: 18/19 passing (1 pending for `ParagraphBidiInfo.reordered_levels` verification)

## Upstream

- **Source**: https://github.com/servo/unicode-bidi.git
- **Version**: v0.3.18 (commit 580b9c6)
- **Documentation**: https://docs.rs/unicode-bidi
- **Crystal API Documentation**: See `docs/` directory for detailed architecture and usage

## License

MIT - See [LICENSE](LICENSE) file for details.