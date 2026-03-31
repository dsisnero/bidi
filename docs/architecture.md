# Architecture

## Overview

This is a Crystal port of the Rust `unicode-bidi` crate, which implements the Unicode Bidirectional Algorithm (UBA) as defined in [Unicode Technical Report #9](https://www.unicode.org/reports/tr9/).

## Source Structure

- `vendor/unicode-bidi/` - Upstream Rust source (git submodule)
- `src/` - Crystal implementation
- `spec/` - Crystal tests/specs
- `plans/inventory/` - Parity tracking manifests

## Key Components

### From Upstream (Rust `unicode-bidi` v0.3.18)

The Rust crate provides:
- `BidiClass` enumeration for Unicode bidi classes
- `BidiInfo` struct for paragraph-level analysis
- `ParagraphBidiInfo` struct for single-paragraph analysis
- `Level` type for embedding levels (0-125, even=LTR, odd=RTL)
- `Direction` enum (Ltr, Rtl, Mixed)
- UTF-16 variants: `BidiInfo` and `ParagraphBidiInfo` for `Vec<u16>` text
- Reordering and visual runs computation
- Base direction detection

### Crystal Port (Complete Implementation)

The Crystal port mirrors the Rust API with exact behavioral parity:

#### Core Types
- `Bidi::BidiClass` - Unicode bidi classes (L, R, AL, EN, ES, ET, AN, CS, NSM, BN, B, S, WS, ON, LRI, RLI, FSI, PDI, LRE, RLE, LRO, RLO, PDF)
- `Bidi::Level` - Embedding levels (0-125, even=LTR, odd=RTL)
- `Bidi::Direction` - Paragraph direction (Ltr, Rtl, Mixed)

#### Main APIs
- `Bidi::BidiInfo` - Multi-paragraph analysis for UTF-8 text
- `Bidi::ParagraphBidiInfo` - Single-paragraph analysis for UTF-8 text
- `Bidi::UTF16::BidiInfo` - Multi-paragraph analysis for UTF-16 text
- `Bidi::UTF16::ParagraphBidiInfo` - Single-paragraph analysis for UTF-16 text

#### Key Methods
- `new(text, default_para_level)` - Analyze text with optional base direction
- `reorder_line(line_range)` - Reorder text for visual display
- `visual_runs(line_range)` - Get visual runs with levels
- `reordered_levels(line_range)` - Get levels after applying L1-L2 rules
- `has_rtl?` / `has_ltr?` - Check text directionality
- `direction` - Get paragraph direction
- `Bidi.get_base_direction(text)` - Detect base direction from text

#### Type Mappings
- Rust `enum` → Crystal `enum`
- Rust `struct` → Crystal `struct`
- Rust `Vec<T>` → Crystal `Array(T)`
- Rust `&str` → Crystal `String`
- Rust `Vec<u16>` → Crystal `Array(UInt16)`
- Rust `Range<usize>` → Crystal `Range(Int32, Int32)`

## Data Flow

### UTF-8 Processing
1. **Input**: `String` text with optional `Level` base direction
2. **Character Analysis**: Determine `BidiClass` for each character using hardcoded Unicode data
3. **Paragraph Segmentation**: Split text by paragraph separators (B, S classes)
4. **Explicit Level Resolution**: Apply rules X1-X9 for explicit formatting characters
5. **Implicit Level Resolution**: Apply rules W1-W7, N1-N2 for weak and neutral characters
6. **L1-L2 Rules**: Reset whitespace to paragraph level, reorder runs for visual display
7. **Output**: Reordered text or visual runs for display

### UTF-16 Processing
Same as UTF-8 but operates on `Array(UInt16)` with surrogate pair handling:
- Surrogate pairs (high: 0xD800-0xDBFF, low: 0xDC00-0xDFFF) treated as single characters
- Invalid sequences replaced with U+FFFD (REPLACEMENT CHARACTER)

## Implementation Details

### Critical Design Decisions
1. **Byte vs Character Indexing**: All APIs use byte indices for UTF-8, code unit indices for UTF-16
2. **String Slicing**: Uses `byte_slice` for UTF-8 to handle multi-byte characters correctly
3. **Surrogate Pair Handling**: UTF-16 implementation preserves surrogate pairs when reversing text
4. **Empty Text Handling**: `get_base_direction("")` returns `Ltr` (matching Rust behavior)
5. **Level Comparison**: `Level` struct implements comparison operators based on underlying `UInt8` value

### Performance Considerations
- Unicode data is hardcoded (from upstream) for fast lookups
- Level runs are computed incrementally
- String operations optimized with `byte_slice` to avoid character iteration
- UTF-16 surrogate pair detection uses range checks for speed

## Dependencies

- Crystal standard library
- Unicode data (embedded from upstream `vendor/unicode-bidi` crate)
- Development: `ameba` for linting

## Testing Strategy

1. **Original Test Suite**: 86 tests covering core functionality
2. **Rust API Compatibility Tests**: 19 tests ported from Rust's public API tests
3. **UTF-16 Specific Tests**: Edge cases for surrogate pairs and invalid sequences
4. **Parity Verification**: Regular comparison with Rust test outputs

## Error Handling

- Invalid UTF-16 sequences replaced with U+FFFD
- Level values validated (0-125 range)
- Range bounds checked in public APIs
- Returns empty results for empty input ranges