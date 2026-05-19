# Development Guide

## Setup

```bash
git clone https://github.com/dsisnero/bidi.git
cd bidi
git submodule update --init
make install
```

## Daily Workflow

```bash
make format     # Format code (crystal tool format)
make lint       # Lint (format check + ameba)
make test       # Run unit specs (92 examples)
crystal spec    # Run full spec suite (123 examples including conformance)
```

## Source Structure

| Dir | Purpose |
|-----|---------|
| `src/bidi/` | Crystal implementation — mirrors `vendor/unicode-bidi/src/` |
| `vendor/unicode-bidi/` | Rust upstream (git submodule, v0.3.18) — source of truth |
| `spec/` | Crystal test specs |
| `spec/data/` | Conformance test data (`BidiTest.txt`, `BidiCharacterTest.txt`) |
| `plans/inventory/` | Parity tracking manifests |
| `plans/parity.md` | Feature checklist and work plan |
| `scripts/` | Parity tooling (manifest gen, check, adversarial verify) |
| `docs/` | Documentation |

## Porting Workflow

### 1. Study Upstream

Read the Rust source in `vendor/unicode-bidi/src/`. Run the Rust tests:

```bash
cd vendor/unicode-bidi
cargo test
```

### 2. Check Parity

```bash
./scripts/check_port_inventory.sh . plans/inventory/rust_port_inventory.tsv vendor/unicode-bidi rust
./scripts/check_source_parity.sh . plans/inventory/rust_source_parity.tsv vendor/unicode-bidi rust
./scripts/check_test_parity.sh . plans/inventory/rust_test_parity.tsv vendor/unicode-bidi rust
```

### 3. Implement

Match Rust behavior exactly:
- Same algorithm, same edge cases, same error conditions
- Use `UInt8`, `Int32`, etc. for numeric types
- Preserve API surface and method signatures

### 4. Port Tests

Crystal specs in `spec/` correspond to Rust `#[test]` functions:
- `src/level.rs` → `spec/level_spec.cr`
- `src/lib.rs` → `spec/info_spec.cr`
- `src/prepare.rs` → `spec/prepare_spec.cr`
- `src/char_data/mod.rs` → `spec/bidi_spec.cr`
- `src/utf16.rs` → `spec/utf16_spec.cr`

### 5. Update Inventory

After porting, update `plans/inventory/rust_port_inventory.tsv` with `ported` status and `crystal_refs`.

### 6. Verify

```bash
make test
crystal spec
./scripts/verify_parity_adversarial.sh . vendor/unicode-bidi rust 'crystal spec' 'cargo test'
```

## Conventions

- Follow existing patterns in `src/bidi/` — naming, struct layout, method visibility
- Crystal `enum` for Rust `enum`, `struct` for `struct`
- Rust `Vec<T>` → Crystal `Array(T)`
- Rust `Option<T>` → Crystal `T?` or nil
- Rust `Range<usize>` → Crystal `Range(Int32, Int32)`
- Do not simplify algorithms; preserve stateful internals even if surface logic looks equivalent

## Debugging Discrepancies

1. Run the Rust test to see expected output
2. Compare Crystal implementation line-by-line
3. Check byte-vs-character indexing (Crystal `String#[]?` uses character indices)
4. Check range end conventions (inclusive vs exclusive)
5. Use `plans/parity.md` to check known issues

## Quality Gates

All must pass before commit:

```bash
make format && make lint && make test
./scripts/verify_parity_adversarial.sh . vendor/unicode-bidi rust 'crystal spec' 'cargo test'
```
