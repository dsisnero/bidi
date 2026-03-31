# Architecture

## Overview

This is a Crystal port of the Rust `unicode-bidi` crate, which implements the Unicode Bidirectional Algorithm (UBA) as defined in [Unicode Technical Report #9](https://www.unicode.org/reports/tr9/).

## Source Structure

- `vendor/unicode-bidi/` - Upstream Rust source (git submodule)
- `src/` - Crystal implementation
- `spec/` - Crystal tests/specs
- `plans/inventory/` - Parity tracking manifests

## Key Components

### From Upstream

The Rust crate provides:
- `BidiClass` enumeration for Unicode bidi classes
- `BidiInfo` struct for paragraph-level analysis
- `Level` type for embedding levels
- `Paragraph` handling
- Reordering and visual runs

### Crystal Port

The Crystal port will mirror the Rust API with appropriate type mappings:
- Rust `enum` → Crystal `enum` or tagged union
- Rust `struct` → Crystal `struct`
- Rust `Vec<T>` → Crystal `Array(T)`
- Rust `HashMap<K, V>` → Crystal `Hash(K, V)`

## Data Flow

1. **Input**: Unicode text with optional base direction
2. **Analysis**: Determine bidi classes and embedding levels
3. **Resolution**: Apply rules from UBA
4. **Output**: Reordered visual runs for display

## Dependencies

- Crystal standard library
- Unicode data (embedded from upstream)