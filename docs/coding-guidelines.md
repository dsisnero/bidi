# Coding Guidelines

## Crystal Style

Follow standard Crystal conventions:
- Use 2-space indentation
- Use snake_case for methods and variables
- Use CamelCase for classes and modules
- Use UPPER_SNAKE_CASE for constants

## Porting Rules

### Behavior Preservation

- Preserve upstream behavior exactly
- Match error conditions and edge cases
- Keep the same API surface
- Maintain identical semantics

### Type Mapping

| Rust Type | Crystal Type | Notes |
|-----------|--------------|-------|
| `u8`, `i32`, etc. | `UInt8`, `Int32`, etc. | Use explicit widths |
| `Vec<T>` | `Array(T)` | |
| `HashMap<K, V>` | `Hash(K, V)` | |
| `Option<T>` | `T?` or `Nil \| T` | |
| `Result<T, E>` | Exception or union type | Match error behavior |
| `&[u8]` | `Bytes` (`Slice(UInt8)`) | For binary data |
| `String` | `String` | For Unicode text |

### Error Handling

- Match Rust's `Result` patterns with Crystal exceptions
- Preserve error messages and conditions
- Use `raise` for panics

### Documentation

- Port Rust doc comments to Crystal doc comments
- Include examples from upstream
- Note any deviations from upstream

## Code Organization

- Mirror Rust module structure
- Keep similar file organization
- Preserve public/private visibility

## Testing

- Port all Rust tests
- Use same test data
- Verify same outputs
- Add characterization tests for undocumented behavior