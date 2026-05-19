# Pull Request Workflow

## Before Starting

Check parity status:

```bash
./scripts/check_port_inventory.sh . plans/inventory/rust_port_inventory.tsv vendor/unicode-bidi rust
./scripts/check_source_parity.sh . plans/inventory/rust_source_parity.tsv vendor/unicode-bidi rust
./scripts/check_test_parity.sh . plans/inventory/rust_test_parity.tsv vendor/unicode-bidi rust
```

## Branch Naming

```
feat/port-<feature-name>
fix/<what-is-fixed>
test/port-<test-name>
refactor/<what-is-refactored>
docs/<what-is-documented>
```

## Development Process

### 1. Implement

- Port Rust code to Crystal in `src/bidi/`
- Match upstream behavior exactly (algorithm, edge cases, error conditions)
- Follow [Coding Guidelines](coding-guidelines.md)

### 2. Test

```bash
make test              # Unit tests (92 examples)
crystal spec           # Full suite (123 examples)
```

### 3. Quality Gates

```bash
make format            # crystal tool format
make lint              # format check + ameba
make test              # unit specs
./scripts/verify_parity_adversarial.sh . vendor/unicode-bidi rust 'crystal spec' 'cargo test'
```

### 4. Update Manifests

After porting items, update `plans/inventory/rust_port_inventory.tsv`:
- Set status to `ported` or `partial`
- Fill `crystal_refs` with file:line references
- Add notes for any intentional divergences

### 5. Commit

```bash
git add -A
git commit -m "feat(bidi): port <feature>

- <change 1>
- <change 2>
- Update inventory status for N items"
```

## PR Checklist

### Code Quality
- [ ] `make format` passes
- [ ] `make lint` passes
- [ ] `make test` passes
- [ ] `crystal spec` passes (123 examples, 0 failures)
- [ ] `./scripts/verify_parity_adversarial.sh` passes

### Porting Completeness
- [ ] Behavior matches upstream exactly
- [ ] All relevant Rust tests ported
- [ ] `crystal_refs` filled in inventory for ported items
- [ ] No new `[ ]` items in `plans/parity.md`

### Documentation
- [ ] Code comments match upstream where applicable
- [ ] README.md updated if API surface changes
- [ ] Docs updated if pipeline or conventions change
- [ ] Inventory notes are clear

## PR Template

```markdown
## Summary

Port [feature] from Rust unicode-bidi v0.3.18.

## Changes

- [list specific code changes with file:line references]

## Inventory Updates

Updated `rust_port_inventory.tsv`:
- [list items with old status → new status]

## Testing

- [describe tests ported/added]
- `make test`: 92 examples, 0 failures
- `crystal spec`: 123 examples, 0 failures
```
