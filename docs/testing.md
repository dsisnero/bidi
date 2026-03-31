# Testing Guide

## Test Strategy

### Unit Tests

Port all Rust `#[test]` functions to Crystal specs:
- One spec file per source file
- Same test names and structure
- Identical assertions

### Integration Tests

Use upstream test data:
- `BidiTest.txt` - Comprehensive bidi tests
- `BidiCharacterTest.txt` - Character-level tests
- UDHR texts - Real-world examples

### Property Tests

Consider using property-based testing for:
- Edge cases
- Round-trip properties
- Invariant preservation

## Running Tests

```bash
# Run all tests
make test

# Run specific test file
crystal spec spec/bidi_spec.cr

# Run with verbose output
crystal spec --verbose
```

## Test Data

Test data is stored in:
- `vendor/unicode-bidi/tests/data/` - Upstream test files
- `spec/fixtures/` - Local test fixtures (to be created)

## Adding Tests

### Porting Rust Tests

1. Find the Rust test in `vendor/unicode-bidi/`
2. Create equivalent Crystal spec
3. Use same test data
4. Verify same expected results

### Creating New Tests

When upstream lacks tests:
1. Create characterization tests
2. Document as "inferred behavior"
3. Mark with `# NOTE: Inferred from upstream behavior`

## Debugging Test Failures

1. Run the Rust test to see expected behavior
2. Compare with Crystal implementation
3. Check type conversions
4. Verify boundary conditions

## Test Coverage

Aim for:
- 100% of ported functionality
- All upstream test cases
- Edge cases and error conditions