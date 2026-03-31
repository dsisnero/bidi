# bidi

Crystal port of Rust unicode-bidi crate

## Commands

```bash
make install    # Install dependencies (shards install)
make update     # Update dependencies (shards update)
make format     # Format code (crystal tool format)
make lint       # Lint code (format check + ameba)
make test       # Run tests (crystal spec)
make clean      # Clean build artifacts
```

## Documentation

| Document | Purpose |
|----------|---------|
| [Architecture](docs/architecture.md) | System design, data flow, package responsibilities |
| [Development](docs/development.md) | Prerequisites, setup, daily workflow |
| [Coding Guidelines](docs/coding-guidelines.md) | Code style, error handling, naming conventions |
| [Testing](docs/testing.md) | Test commands, conventions, patterns |
| [PR Workflow](docs/pr-workflow.md) | Commits, PRs, branch naming, review process |

## Core Principles

1. Upstream behavior is source of truth
2. Preserve Unicode semantics exactly
3. Test parity is first-class work

## Commits

Format: `<type>(<scope>): <description>`

Types: feat, fix, docs, refactor, test, chore, perf

Examples:
- `feat(bidi): add paragraph-level analysis`
- `fix(level): correct embedding level calculation`
- `test(conformance): port BidiTest.txt validation`

## External Dependencies

- **Upstream Rust crate**: `vendor/unicode-bidi/` (git submodule pinned to v0.3.18)
- **Unicode data**: Embedded from upstream source
- **Crystal shards**: ameba (development dependency for linting)

## Debugging

When debugging discrepancies:
1. Run the Rust test to see expected behavior
2. Compare with Crystal implementation
3. Check type mappings and boundary conditions
4. Use inventory scripts to track parity status

## Conventions

- Follow Rust → Crystal mapping patterns from AGENTS.md
- Use explicit numeric types (UInt8, Int32, etc.) for behavior-dependent code
- Preserve error behavior identical to upstream
- Document any unavoidable deviations from upstream