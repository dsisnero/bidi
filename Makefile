.PHONY: install update format lint test clean

# Install dependencies
install:
	shards install

# Update dependencies
update:
	shards update

# Format code
format:
	crystal tool format src spec

# Lint code
lint:
	crystal tool format --check src spec
	ameba src spec

# Run tests (excluding slow conformance tests)
test:
	crystal spec spec/info_spec.cr spec/utf16_spec.cr spec/level_spec.cr spec/prepare_spec.cr spec/bidi_spec.cr spec/integration_spec.cr

# Clean build artifacts
clean:
	rm -rf .crystal-cache/ bin/