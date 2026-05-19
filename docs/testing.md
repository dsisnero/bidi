# Testing Guide

## Test Suite Layout

| Spec file | Tests | Covers |
|-----------|-------|--------|
| `spec/level_spec.cr` | 12 | `Level` construction, raise/lower, is_ltr, is_rtl, vec, has_rtl |
| `spec/bidi_spec.cr` | 4 | `BidiClass` lookups (ASCII, BMP, SMP, unassigned) |
| `spec/info_spec.cr` | 12 | `BidiInfo`, `ParagraphBidiInfo`, direction, reorder_line, reordered_levels, has_rtl, paragraph_info_len |
| `spec/prepare_spec.cr` | 7 | Level runs, isolating run sequences (BD13), sos/eos, removed_by_x9 |
| `spec/utf16_spec.cr` | 10 | `UTF16::BidiInfo`, `ParagraphBidiInfo`, char_at, each_char, surrogate pairs |
| `spec/rust_api_spec.cr` | 19 | Rust API compatibility: BidiInfo methods, ParagraphBidiInfo, visual_runs, has_rtl, Paragraph |
| `spec/integration_spec.cr` | 6 | Multi-paragraph, bracket pairs, embedding controls, neutral chars |
| `spec/conformance_full_spec.cr` | 3 | Full `BidiTest.txt` + `BidiCharacterTest.txt` validation |
| `spec/conformance_simple_spec.cr` | 3 | Subset of conformance tests for fast development feedback |

## Running Tests

```bash
# Full suite (123 examples)
crystal spec

# Unit tests only (92 examples, no conformance)
make test

# Specific spec file
crystal spec spec/info_spec.cr

# Specific test within a file
crystal spec spec/info_spec.cr:173

# Verbose output
crystal spec --verbose

# Run Rust upstream tests for comparison
cd vendor/unicode-bidi && cargo test
```

## Test Data

- `vendor/unicode-bidi/tests/data/BidiTest.txt` — comprehensive bidi conformance
- `vendor/unicode-bidi/tests/data/BidiCharacterTest.txt` — character-level conformance
- Both copied to `spec/data/` for local access

## Conformance Tests

The conformance tests validate against Unicode's official test data:

- **`test_basic_conformance`** (`spec/conformance_full_spec.cr:7`): Processes every line of `BidiTest.txt`, verifying levels and ordering for each base direction (auto-LTR, LTR, RTL). Also cross-validates UTF-8 vs UTF-16 output consistency.

- **`test_character_conformance`** (`spec/conformance_full_spec.cr:210`): Processes `BidiCharacterTest.txt`, verifying per-character behavior including bracket pair, isolate, and embedding cases.

These tests are slow (30–60 seconds) and are excluded from `make test`. Run with `crystal spec spec/conformance_full_spec.cr`.

## Adding Tests

### Porting from Rust

1. Find the Rust `#[test] fn test_*()` in `vendor/unicode-bidi/src/`
2. Create equivalent `it "does X"` block in the matching Crystal spec file
3. Use same input data and expected values
4. Verify against Rust output before committing

### Crystal Test Patterns

```crystal
require "./spec_helper"

describe Bidi::BidiInfo do
  it "does something" do
    text = "Hello"
    info = Bidi::BidiInfo.new(text, nil)
    info.paragraphs.size.should eq 1
    info.paragraphs[0].level.should eq Bidi::Level.ltr
  end
end
```

### Debugging Failing Tests

1. Run the equivalent Rust test for expected behavior
2. Add debug output (`puts`, `pp`) to trace data flow
3. Check for byte-vs-character indexing issues (use `byte_index_to_char_index`)
4. Verify range conventions (inclusive vs exclusive end)
5. Check `parity.md` for known pipeline issues

## Test Status

```
make test:  92 examples, 0 failures, 0 errors, 0 pending
crystal spec: 123 examples, 0 failures, 0 errors, 0 pending
Rust cargo test: 42 passed, 0 failed
Adversarial verification: PASSED
```
