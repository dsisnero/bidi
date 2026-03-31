# Development Guide

## Getting Started

```bash
# Clone the repository
git clone https://github.com/dsisnero/bidi.git
cd bidi

# Initialize submodules
git submodule update --init

# Install dependencies
make install
```

## Porting Workflow

### 1. Understand Upstream

Examine the Rust source in `vendor/unicode-bidi/`:
- Read the Rust documentation
- Study test cases
- Understand the API surface

### 2. Update Inventory

Before implementing, update the parity inventory:

```bash
# Check current parity status
./scripts/check_port_inventory.sh . plans/inventory/rust_port_inventory.tsv vendor/unicode-bidi rust
```

### 3. Implement in Crystal

Follow Rust → Crystal mapping patterns:
- Preserve behavior exactly
- Use appropriate Crystal types
- Add Crystal documentation

### 4. Port Tests

For each Rust test, create a Crystal spec:
- Copy test logic exactly
- Use same test data/fixtures
- Verify same expected outputs

### 5. Verify Quality

```bash
make format  # Format code
make lint    # Check formatting and lint
make test    # Run tests
```

## Testing Strategy

### Unit Tests

Port Rust unit tests (`#[test]` functions) to Crystal specs.

### Integration Tests

Use upstream test data files:
- `vendor/unicode-bidi/tests/data/BidiTest.txt`
- `vendor/unicode-bidi/tests/data/BidiCharacterTest.txt`

### Property Tests

Consider using Crystal's `spec` property testing for edge cases.

## Debugging

### Compare with Rust

When debugging discrepancies:
1. Run the Rust test to see expected behavior
2. Compare with Crystal implementation
3. Check type mappings and boundary conditions

### Logging

Add debug logging temporarily to understand data flow differences.

## Code Review Checklist

- [ ] Behavior matches upstream exactly
- [ ] Tests are ported completely
- [ ] Crystal idioms are used appropriately
- [ ] Documentation is updated
- [ ] Inventory status is current
- [ ] Quality gates pass