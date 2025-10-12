# Gexd CLI

A powerful command-line tool for generating Flutter projects with GetX and Clean Architecture templates.

## Development

This project includes a `Makefile` for common development tasks:

### Quick Start
```bash
# Setup development environment
make setup

# Quick development cycle (format + analyze + unit tests)  
make quick

# Run all tests
make test
```

### Available Commands
```bash
make help           # Show all available commands
make deps          # Get dependencies
make format        # Format code
make analyze       # Analyze code
make test-unit     # Run unit tests only
make test-e2e      # Run E2E tests only
make build         # Build executable
make install       # Install globally
make clean         # Clean build artifacts
make pre-commit    # Pre-commit checks
```

### Testing
The project uses a tag-based testing system:
- `unit` - Fast unit tests (< 30s)
- `integration` - Integration tests (30s-2m)
- `e2e` - End-to-end tests (2m+)
- `smoke` - Essential smoke tests

See [TEST_TAGS_GUIDE.md](TEST_TAGS_GUIDE.md) for detailed testing information.
