# bidi

Crystal port of the [Rust `unicode-bidi` crate](https://github.com/servo/unicode-bidi) (v0.3.18) — Unicode Bidirectional Algorithm implementation for mixed RTL/LTR text display.

[![Build Status](https://img.shields.io/github/actions/workflow/status/dsisnero/bidi/ci.yml?style=flat-square)](https://github.com/dsisnero/bidi/actions)
[![License](https://img.shields.io/github/license/dsisnero/bidi?style=flat-square)](LICENSE)

---

## Quick Start

```bash
git clone https://github.com/dsisnero/bidi.git
cd bidi
git submodule update --init
make install
make test
```

## Example

```crystal
require "bidi"

text = "Hello שלום"  # Mixed LTR/RTL text
info = Bidi::BidiInfo.new(text, nil)

para = info.paragraphs[0]
reordered = info.reorder_line(para, para.range)
puts reordered  # "Hello םולש"

# Single paragraph API
info = Bidi::ParagraphBidiInfo.new(text, nil)
puts info.reorder_line(0...text.bytesize)

# Base direction detection
puts Bidi.get_base_direction("Hello")  # Ltr
puts Bidi.get_base_direction("שלום")   # Rtl
```

## API

| Rust API | Crystal | Status |
|----------|---------|--------|
| `BidiInfo` | `Bidi::BidiInfo` | ✅ |
| `ParagraphBidiInfo` | `Bidi::ParagraphBidiInfo` | ✅ |
| `UTF16::BidiInfo` | `Bidi::UTF16::BidiInfo` | ✅ |
| `UTF16::ParagraphBidiInfo` | `Bidi::UTF16::ParagraphBidiInfo` | ✅ |
| `Level` | `Bidi::Level` | ✅ |
| `BidiClass` | `Bidi::BidiClass` | ✅ |
| `Direction` | `Bidi::Direction` | ✅ |
| `get_base_direction` | `Bidi.get_base_direction` | ✅ |
| `reorder_visual` | `Bidi::BidiInfo.reorder_visual` | ✅ |

## Source Map

| Rust (`vendor/unicode-bidi/src/`) | Crystal (`src/bidi/`) |
|-----------------------------------|----------------------|
| `char_data/mod.rs`, `tables.rs` | `char_data.cr`, `char_data/tables.cr`, `char_data/tables_data.cr` |
| `level.rs` | `level.cr` |
| `format_chars.rs` | `format_chars.cr` |
| `data_source.rs` | `data_source.cr` |
| `explicit.rs` | `explicit.cr` |
| `prepare.rs` | `prepare.cr` |
| `implicit.rs` | `implicit.cr` |
| `lib.rs` | `info.cr`, `bidi_info_common.cr` |
| `utf16.rs` | `utf16.cr` |
| `deprecated.rs` | (not ported) |

## Development

```bash
make install    # Install dependencies (shards install)
make update     # Update dependencies (shards update)
make format     # Format code (crystal tool format)
make lint       # Lint code (format check + ameba)
make test       # Run tests (crystal spec)
make clean      # Clean build artifacts
```

## Documentation

| Document | Purpose |
|----------|---------|
| [Architecture](docs/architecture.md) | System design, data flow, type mappings |
| [Development](docs/development.md) | Setup, workflow, debugging |
| [Coding Guidelines](docs/coding-guidelines.md) | Code style, error handling, naming |
| [Testing](docs/testing.md) | Test commands, spec file layout |
| [Examples](docs/examples.md) | Usage examples for common scenarios |
| [PR Workflow](docs/pr-workflow.md) | Commits, PRs, review process |
| [Parity Tracker](plans/parity.md) | Port status, feature checklist, work plan |

## Test Status

| Suite | Count | Pass | Fail | Errors | Pending |
|-------|-------|------|------|--------|---------|
| Full spec | 123 | 123 | 0 | 0 | 0 |
| Unit tests (`make test`) | 92 | 92 | 0 | 0 | 0 |
| Rust upstream tests | 42 | 42 | 0 | 0 | 0 |
| Parity manifest checks | 3 | 3 | 0 | — | — |

## Upstream

- **Source**: [servo/unicode-bidi](https://github.com/servo/unicode-bidi) (v0.3.18)
- **Vendor**: `vendor/unicode-bidi/` (git submodule)
- **Docs**: [docs.rs/unicode-bidi](https://docs.rs/unicode-bidi)

## License

MIT — see [LICENSE](LICENSE).
