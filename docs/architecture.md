# Architecture

## Overview

This Crystal port of [Rust `unicode-bidi`](https://github.com/servo/unicode-bidi) v0.3.18 implements the Unicode Bidirectional Algorithm per [UAX #9](https://www.unicode.org/reports/tr9/). Every public API and internal pipeline stage is preserved identically.

## Source Layout

```
vendor/unicode-bidi/src/          →   src/bidi/
  char_data/mod.rs    (char data)       char_data.cr + char_data/tables.cr + char_data/tables_data.cr
  level.rs            (Level struct)    level.cr
  format_chars.rs     (constants)       format_chars.cr
  data_source.rs      (trait + struct)  data_source.cr
  explicit.rs         (X1-X8)           explicit.cr
  prepare.rs          (X9-X10, BD7)     prepare.cr
  implicit.rs         (W1-W7,N0-N2,I1-2) implicit.cr
  lib.rs              (BidiInfo API)    info.cr + bidi_info_common.cr
  utf16.rs            (UTF-16 support)  utf16.cr
  deprecated.rs       (legacy)          (not ported)
```

## Pipeline

### UTF-8 Processing (`src/bidi/info.cr`)

1. **`InitialInfoExt.new_with_data_source`** — scans characters, assigns `BidiClass`, splits paragraphs at B/S class chars, auto-detects paragraph level from first strong char (P2-P3)
2. **`compute_explicit`** (`explicit.cr`) — applies X1-X8 (explicit embedding/override/isolate), produces level runs (BD7)
3. **`isolating_run_sequences`** (`prepare.cr`) — groups level runs into isolating run sequences (X9-X10)
4. **`resolve_weak`** (`implicit.cr`) — applies W1-W7 (weak types)
5. **`resolve_neutral`** (`implicit.cr`) — applies N0-N2 (neutral types, bracket pairs)
6. **`resolve_levels`** (`implicit.cr`) — applies I1-I2 (implicit levels)
7. **`assign_levels_to_removed_chars`** — fills levels for X9-removed formatting chars
8. **`reorder_levels` (L1)** — resets trailing whitespace/formatting to paragraph level
9. **`visual_runs` (L2)** — reverses runs at odd levels for visual order
10. **`reorder_line`** — produces display-order string by concatenating reversed RTL runs

### UTF-16 Processing (`src/bidi/utf16.cr`)

Same pipeline but operates on `Array(UInt16)` code units with surrogate pair handling:
- High surrogate (0xD800–0xDBFF) + low surrogate (0xDC00–0xDFFF) → single character
- Unpaired surrogates → U+FFFD replacement character
- `char_at` returns nil for mid-surrogate positions (not a character boundary)

## Core Types

| Rust | Crystal | File |
|------|---------|------|
| `BidiClass` enum (23 variants) | `Bidi::BidiClass` | `char_data/tables.cr:8` |
| `Level(u8)` struct (0–125) | `Bidi::Level` | `level.cr:23` |
| `Direction` enum (Ltr, Rtl, Mixed) | `Bidi::Direction` | `info.cr:26` |
| `BidiInfo<'text>` | `Bidi::BidiInfo` | `info.cr:204` |
| `ParagraphBidiInfo<'text>` | `Bidi::ParagraphBidiInfo` | `info.cr:595` |
| `ParagraphInfo` | `Bidi::ParagraphInfo` | `info.cr:37` |
| `IsolatingRunSequence` | `Bidi::IsolatingRunSequence` | `prepare.cr:13` |
| `HardcodedBidiData` | `HardcodedBidiData` | `char_data.cr:6` |

## Type Mappings

| Rust | Crystal |
|------|---------|
| `enum` | `enum` |
| `struct` | `struct` |
| `Vec<T>` | `Array(T)` |
| `&str` | `String` |
| `Vec<u16>` | `Array(UInt16)` |
| `Range<usize>` | `Range(Int32, Int32)` |
| `Option<T>` | `T?` |
| `trait` | module/abstract struct |

## Key Design Decisions

1. **Byte-indexed arrays**: `original_classes` and `levels` are indexed by byte position (UTF-8) or code unit position (UTF-16), matching Rust
2. **`byte_slice` for substrings**: avoids mid-character slicing on multi-byte UTF-8
3. **Inclusive-end level runs**: internal run representation uses inclusive end indices; iterated correctly via `Range#each`
4. **`byte_index_to_char_index` bridge**: Crystal's `String#[]?` uses character indices, so byte positions must be converted before character access
5. **Empty text**: returns `Ltr` direction with empty levels/paragraphs (matching Rust)

## Testing

| Spec file | Covers |
|-----------|--------|
| `spec/level_spec.cr` | `Level` construction, raise/lower, is_ltr/is_rtl |
| `spec/bidi_spec.cr` | `BidiClass` lookups, `BidiInfo` construction |
| `spec/info_spec.cr` | `BidiInfo`, `ParagraphBidiInfo`, direction, reorder_line, has_rtl |
| `spec/prepare_spec.cr` | Level runs, isolating run sequences, sos/eos |
| `spec/utf16_spec.cr` | `UTF16::BidiInfo`, char iterator, surrogate handling |
| `spec/rust_api_spec.cr` | Rust API compatibility (reorder_line, visual_runs, ParagraphBidiInfo) |
| `spec/integration_spec.cr` | Multi-paragraph, bracket pairs, embedding controls |
| `spec/conformance_full_spec.cr` | Full `BidiTest.txt` and `BidiCharacterTest.txt` validation |

## Dependencies

- Crystal stdlib only (no external shards)
- Unicode data embedded from upstream `vendor/unicode-bidi/src/char_data/tables.rs`
- Dev: `ameba` for linting
