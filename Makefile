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

# Run tests
test:
	crystal spec

# Clean build artifacts
clean:
	rm -rf .crystal-cache/ bin/