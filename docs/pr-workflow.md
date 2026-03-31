# Pull Request Workflow

## Before Starting

1. **Check inventory status**:
   ```bash
   ./scripts/check_port_inventory.sh . plans/inventory/rust_port_inventory.tsv vendor/unicode-bidi rust
   ```

2. **Update inventory** if working on new items.

## Development Process

### 1. Create Feature Branch

```bash
git checkout -b feature/port-bidi-class
```

### 2. Implement Changes

- Port Rust code to Crystal
- Add/update Crystal specs
- Update inventory status

### 3. Run Quality Gates

```bash
make format
make lint
make test
```

### 4. Update Documentation

- Update README if API changes
- Add/update code comments
- Update inventory notes

### 5. Commit Changes

Use descriptive commit messages:
```
Port BidiClass enum and related functions

- Add BidiClass enum with all Unicode bidi classes
- Port bidi_class() lookup function
- Add unit tests from upstream
- Update inventory status for 5 items
```

## PR Checklist

### Code Quality
- [ ] `make format` passes
- [ ] `make lint` passes
- [ ] `make test` passes
- [ ] No new warnings

### Porting Completeness
- [ ] Behavior matches upstream exactly
- [ ] All relevant tests ported
- [ ] Inventory status updated
- [ ] `crystal_refs` filled for ported items

### Documentation
- [ ] Code comments added/updated
- [ ] README updated if needed
- [ ] Inventory notes clear

### Review Ready
- [ ] PR description explains changes
- [ ] Linked to inventory items
- [ ] Ready for review

## PR Description Template

```markdown
## Summary

Port [feature] from Rust unicode-bidi v0.3.18.

## Changes

- [List specific changes]

## Inventory Updates

- Updated `rust_port_inventory.tsv`:
  - [List specific items with status changes]

## Testing

- [Describe tests added/ported]
- [Test results]

## Notes

[Any deviations from upstream or special considerations]
```

## After PR Merge

1. **Sync submodule** if upstream changed:
   ```bash
   git submodule update --remote vendor/unicode-bidi
   ```

2. **Regenerate manifests** if needed:
   ```bash
   ./scripts/ensure_parity_plan.sh . vendor/unicode-bidi rust auto 1
   ```