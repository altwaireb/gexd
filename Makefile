# Makefile for Gexd CLI - Simplified version
# Usage: make <target>

.PHONY: help clean test build install format format-bricks analyze deps check release dev ci build-runner build-runner-watch build-runner-clean build-verify

# Default target
help:
	@echo "Gexd CLI - Available Commands:"
	@echo ""
	@echo "Development:"
	@echo "  deps          - Get dependencies"
	@echo "  format        - Format code (excludes bricks/)"
	@echo "  format-bricks - Format brick templates (use with caution)"
	@echo "  analyze       - Analyze code"
	@echo "  test          - Run all tests"
	@echo "  dev           - Run development tests (fast)"
	@echo ""
	@echo "Testing:"
	@echo "  test-unit - Run unit tests only"
	@echo "  test-smoke- Run smoke tests only"
	@echo "  test-e2e  - Run E2E tests only"
	@echo "  ci        - Run CI tests"
	@echo ""
	@echo "Build & Deploy:"
	@echo "  build     - Build project"
	@echo "  install   - Install globally"
	@echo "  clean     - Clean build artifacts"
	@echo ""
	@echo "Build & Generation:"
	@echo "  build-runner       - Run build runner"
	@echo "  build-runner-watch - Run build runner in watch mode"
	@echo "  build-runner-clean - Clean build runner cache"
	@echo "  build-verify       - Verify build is clean"
	@echo ""
	@echo "Quality:"
	@echo "  check     - Run full quality checks"
	@echo "  quick     - Quick development cycle (format+analyze+test)"
	@echo "  fix       - Apply dart fixes"
	@echo "  pre-commit- Pre-commit checks"
	@echo ""
	@echo "Advanced:"
	@echo "  setup     - Setup development environment"
	@echo "  coverage  - Generate test coverage report"
	@echo "  test-file - Run specific test file"
	@echo ""

# Dependencies
deps:
	@echo "📦 Getting dependencies..."
	dart pub get

# Code formatting (excludes bricks/ to avoid modifying templates)
format:
	@echo "🎨 Formatting code..."
	dart format lib/ test/ bin/

# Format templates (use with caution)
format-bricks:
	@echo "🧱 Formatting brick templates..."
	@echo "⚠️  Warning: This will modify template files!"
	dart format bricks/

# Code analysis
analyze:
	@echo "🔍 Analyzing code..."
	dart analyze

# Apply dart fixes
fix:
	@echo "🔧 Applying dart fixes..."
	dart fix --apply

# Build runner commands
build-runner:
	@echo "🏃 Running build runner..."
	dart run build_runner build

build-runner-watch:
	@echo "👀 Running build runner in watch mode..."
	dart run build_runner watch

build-runner-clean:
	@echo "🧹 Cleaning build runner cache..."
	dart run build_runner clean

# Build verification
build-verify:
	@echo "✅ Verifying build is clean..."
	dart test test/build_verify_test.dart

# Testing targets
test:
	@echo "🧪 Running all tests..."
	dart test

test-unit:
	@echo "⚡ Running unit tests..."
	dart test --tags unit

test-smoke:
	@echo "💨 Running smoke tests..."
	dart test --tags smoke

test-integration:
	@echo "🔗 Running integration tests..."
	dart test --tags integration

test-e2e:
	@echo "🎯 Running E2E tests..."
	dart test --tags e2e

# Development preset
dev:
	@echo "🚀 Running development tests..."
	dart test --preset dev

# CI preset
ci:
	@echo "🤖 Running CI tests..."
	dart test --preset ci

# Build
build:
	@echo "🏗️  Building project..."
	@mkdir -p build
	dart compile exe bin/gexd.dart -o build/gexd

# Install globally
install: build
	@echo "📥 Installing globally..."
	dart pub global activate --source path .

# Clean
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf build/
	rm -rf .dart_tool/build/
	dart pub get

# Quality checks
check: deps analyze test build-verify
	@echo "✅ All quality checks passed!"

# Full development setup
setup: deps
	@echo "🎉 Development environment ready!"
	@echo "Run 'make help' to see available commands"

# Watch tests (requires entr or similar)
watch-test:
	@echo "👀 Watching for changes and running tests..."
	find . -name "*.dart" | entr -c make test-unit

# Coverage (if coverage package is added)
coverage:
	@echo "📊 Generating test coverage..."
	dart test --coverage=coverage
	genhtml coverage/lcov.info -o coverage/html
	@echo "Coverage report generated in coverage/html/"

# Run specific test file
test-file:
	@echo "🎯 Running specific test file..."
	@read -p "Enter test file path: " FILE; dart test $$FILE

# Quick development cycle
quick: format analyze test-unit
	@echo "⚡ Quick development cycle completed!"

# Pre-commit checks
pre-commit: format analyze test-unit build-verify
	@echo "✅ Pre-commit checks passed!"