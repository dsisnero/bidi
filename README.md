<p align="center">
  <strong>Crystal port of Rust unicode-bidi crate</strong><br>
  Unicode Bidirectional Algorithm implementation for mixed RTL/LTR text display
</p>

<p align="center">
  <a href="docs/architecture.md">Architecture</a> &middot;
  <a href="docs/development.md">Development</a> &middot;
  <a href="docs/coding-guidelines.md">Guidelines</a> &middot;
  <a href="docs/testing.md">Testing</a> &middot;
  <a href="docs/pr-workflow.md">PR Workflow</a>
</p>

---

Acts as a translator ensuring right-to-left and left-to-right scripts coexist harmoniously on screen, implementing the Unicode Bidirectional Algorithm to properly display mixed-direction text.

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/dsisnero/bidi.git
cd bidi

# Initialize submodules
git submodule update --init

# Install dependencies
make install

# Run tests
make test
```

## Features

- **Unicode Bidirectional Algorithm**: Full implementation of UBA as defined in Unicode Technical Report #9
- **Rust parity**: Behavior-identical port of the Rust `unicode-bidi` crate
- **Crystal-native API**: Clean Crystal interface with proper type mappings
- **Comprehensive testing**: Ported upstream tests plus Crystal-specific validation
- **Inventory tracking**: Systematic parity tracking with manifest files

## Development

```bash
make install    # Install dependencies
make update     # Update dependencies
make format     # Format code
make lint       # Lint code (format check + ameba)
make test       # Run tests
make clean      # Clean build artifacts
```

See [Development Guide](docs/development.md) for full setup instructions.

## Documentation

| Document | Purpose |
|----------|---------|
| [Architecture](docs/architecture.md) | System design and data flow |
| [Development](docs/development.md) | Setup and daily workflow |
| [Coding Guidelines](docs/coding-guidelines.md) | Code style and conventions |
| [Testing](docs/testing.md) | Test commands and patterns |
| [PR Workflow](docs/pr-workflow.md) | Commits, PRs, and review process |

## Contributing

1. Create an issue: `/forge-create-issue`
2. Implement: `/forge-implement-issue <number>`
3. Self-review: `/forge-reflect-pr`
4. Address feedback: `/forge-address-pr-feedback`
5. Update changelog: `/forge-update-changelog`

## Upstream

- **Source**: https://github.com/servo/unicode-bidi.git
- **Version**: v0.3.18 (commit 580b9c6)
- **Documentation**: https://docs.rs/unicode-bidi

## License

MIT - See [LICENSE](LICENSE) file for details.