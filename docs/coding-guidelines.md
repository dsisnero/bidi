# Coding Guidelines

## Crystal Conventions

- 2-space indentation
- `snake_case` for methods, variables, file names
- `CamelCase` for structs, enums, modules
- `UPPER_SNAKE_CASE` for constants
- `?` suffix for predicate methods (`ltr?`, `rtl?`, `removed_by_x9?`)

## Porting Rules

### Behavior Preservation

This is the primary rule. Every port must:
- Produce identical outputs for identical inputs
- Handle edge cases identically (empty text, overflow, out-of-bounds)
- Preserve error behavior (exception types, messages)
- Keep the same API surface (method names, parameter order, return types)

### Do Not Simplify

Preserve stateful internals even when the surface algorithm looks equivalent:
- Keep the same data structures (stacks, run vectors, state tracking)
- Maintain the same pipeline order (explicit → sequences → weak → neutral → levels → assign)
- Replicate multi-pass algorithms exactly; do not collapse into single-pass

### Type Mappings

| Rust | Crystal |
|------|---------|
| `u8`, `u16`, `u32` | `UInt8`, `UInt16`, `UInt32` |
| `i32`, `usize` | `Int32` |
| `Vec<T>` | `Array(T)` |
| `&str` | `String` |
| `&[u16]` | `Array(UInt16)` |
| `Option<T>` | `T?` |
| `Result<T, E>` | Exception or `T?` |
| `Range<usize>` | `Range(Int32, Int32)` |
| `BTreeMap<K,V>` | `Hash(K, V)` (insertion order not required) |
| `SmallVec<T>` | `Array(T)` (Crystal has no small-vec optimization) |

### String Access — Critical

Crystal's `String#[]?` uses **character** indices, not byte indices. This differs from Rust's byte-indexed `str`. Always convert byte positions to character indices before character access:

```crystal
# WRONG — uses character index
ch = text[byte_pos]?

# CORRECT — converts byte position to character index first
char_idx = text.byte_index_to_char_index(byte_pos)
ch = text[char_idx] if char_idx
```

### Range Conventions

The Crystal port uses inclusive-end ranges (`Range.new(a, b)` = `a..b`). The Rust upstream uses exclusive-end ranges (`a..b`). The internal iteration code handles this consistently:

```crystal
# Crystal (inclusive-end): [0..9] iterates 0,1,2,...,9
run = LevelRun.new(start + current_run_start, start + actual_size - 1)

# Iteration matches behavior across conventions
run.each { |i| ... }  # Correct iteration for both conventions
```

### Enum Predicates

Crystal auto-generates predicate methods for enum values:

```crystal
enum BidiClass; L; R; AL; BN; end
BidiClass::BN.removed_by_x9?  # defined on BidiClass
BidiClass::L.ltr?             # not auto-generated; use == comparison
```

## Code Organization

- Mirror Rust module structure: `src/lib.rs` → `src/bidi/info.cr`
- Keep related logic in the same file as upstream
- Use `private` for internal implementation details
- Use `module Bidi` for the top-level namespace

## Documentation

- Port Rust doc comments verbatim where possible
- Include `# <http://...>` UAX #9 rule references from upstream
- Note any intentional divergences with reason

## Commits

Format: `<type>(<scope>): <description>`

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`

Examples:
- `feat(bidi): add paragraph-level analysis`
- `fix(level): correct embedding level calculation`
- `test(conformance): port BidiTest.txt validation`
