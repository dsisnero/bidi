# bidi Documentation

Crystal port of the Rust [unicode-bidi](https://github.com/servo/unicode-bidi) crate v0.3.18 — Unicode Bidirectional Algorithm (UBA) implementation per [Unicode Technical Report #9](https://www.unicode.org/reports/tr9/).

## Guides

| Document | Content |
|----------|---------|
| [Architecture](architecture.md) | Source layout, data flow, pipeline stages, type mappings |
| [Development](development.md) | Setup, parity workflow, quality gates, debugging |
| [Coding Guidelines](coding-guidelines.md) | Code style, type mappings, error handling |
| [Testing](testing.md) | Spec file layout, test data, running subsets |
| [Examples](examples.md) | Usage examples for common and advanced scenarios |
| [PR Workflow](pr-workflow.md) | Branch naming, commits, review, manifests |

## API Reference

- [API Documentation](api/index.html) — generated from source with `crystal docs`

## Quick Start

```crystal
# Add to shard.yml
dependencies:
  bidi:
    github: dsisnero/bidi
```

```crystal
require "bidi"

# Reorder mixed-direction text
text = "Hello שלום"
info = Bidi::BidiInfo.new(text, nil)
para = info.paragraphs[0]
puts info.reorder_line(para, para.range)  # "Hello םולש"
```

## Key APIs

| API | Purpose |
|-----|---------|
| `Bidi::BidiInfo` | Multi-paragraph UTF-8 analysis (`src/bidi/info.cr`) |
| `Bidi::ParagraphBidiInfo` | Single-paragraph UTF-8 analysis (`src/bidi/info.cr`) |
| `Bidi::UTF16::BidiInfo` | Multi-paragraph UTF-16 analysis (`src/bidi/utf16.cr`) |
| `Bidi::UTF16::ParagraphBidiInfo` | Single-paragraph UTF-16 analysis (`src/bidi/utf16.cr`) |
| `Bidi.get_base_direction` | Auto-detect paragraph direction from text |
| `Bidi::Level` | Embedding level (0–125, even=LTR, odd=RTL) |
| `Bidi::BidiClass` | Unicode Bidi_Class enumeration |
| `Bidi::Direction` | Paragraph direction (Ltr, Rtl, Mixed) |

## Test Status

- **Unit specs** (`make test`): 92 examples, 0 failures
- **Full suite** (`crystal spec`): 123 examples, 0 failures
- **Rust upstream** (`cargo test`): 42 tests, 0 failures
- **Parity manifest**: passes all 3 inventory/source/test checks

See [Parity Tracker](../plans/parity.md) for detailed port status and feature checklist.

## Project Structure

```
src/bidi/           — Crystal implementation (mirrors vendor/unicode-bidi/src/)
spec/               — Crystal test specs
vendor/unicode-bidi/ — Rust upstream (git submodule, v0.3.18)
plans/inventory/     — Parity tracking manifests
docs/                — Documentation
scripts/             — Parity tooling
```
