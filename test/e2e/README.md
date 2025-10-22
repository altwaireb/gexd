# E2E Tests Guide

This directory contains comprehensive End-to-End (E2E) tests for the Gexd CLI tool.

## Test Structure

```
test/e2e/
├── init_command_test.dart      # Init command tests
├── create_command_test.dart    # Create command tests
└── commands/
    └── make/
        ├── screen/
        │   └── screen_command_test.dart     # Screen generation tests
        ├── binding/
        │   └── binding_command_test.dart    # Binding generation tests
        └── controller/
            └── controller_command_test.dart # Controller generation tests
```

## Running Tests

### Run All E2E Tests
```bash
dart test test/e2e/
```

### Run Individual Test Suites
```bash
# Init command tests
dart test test/e2e/init_command_test.dart

# Create command tests  
dart test test/e2e/create_command_test.dart

# Screen command tests
dart test test/e2e/commands/make/screen/screen_command_test.dart

# Binding command tests
dart test test/e2e/commands/make/binding/binding_command_test.dart

# Controller command tests
dart test test/e2e/commands/make/controller/controller_command_test.dart
```

### Test Options
```bash
# Compact output
dart test test/e2e/ --reporter=compact

# Expanded output with details
dart test test/e2e/ --reporter=expanded

# JSON output for CI/CD
dart test test/e2e/ --reporter=json
```

## Test Features

### What's Tested
- ✅ Command validation and error handling
- ✅ File generation and structure verification
- ✅ Template compatibility (GetX & Clean Architecture)
- ✅ Subdirectory organization and validation
- ✅ Force flag and overwrite behavior
- ✅ Performance and quality metrics
- ✅ Cross-template compatibility
- ✅ Edge cases and error scenarios

### Test Optimizations
- **OptimizedTestManager**: Fast template caching and reuse
- **Parallel Execution**: Multiple test scenarios run concurrently
- **Smart Cleanup**: Automatic resource management
- **Performance Tracking**: Execution time monitoring

## Test Categories

### 📋 Pre-conditions & Validation
- Project initialization checks
- Parameter validation
- Help documentation verification
- Error message accuracy

### 🏗️ Core Functionality  
- File creation and structure
- Template integration
- Content verification
- Naming conventions

### 📱 Feature-Specific Tests
- Screen-specific functionality
- Binding integration
- Controller lifecycle methods
- Subdirectory organization

### ⚡ Performance & Quality
- Execution time benchmarks
- Multiple file creation efficiency
- Resource usage optimization
- Code formatting consistency

### 🔄 Cross-Template Compatibility
- GetX template support
- Clean Architecture template support
- Consistent behavior across templates
- Template-specific adaptations

### ⚠️ Edge Cases & Error Handling
- Invalid input handling
- Special character validation
- Long name support
- Graceful failure scenarios

## Contributing

When adding new tests:

1. **Follow the existing pattern**: Use the same structure and naming conventions
2. **Include comprehensive coverage**: Test success paths, validation, and error cases
3. **Use OptimizedTestManager**: For consistent and fast test execution
4. **Add proper documentation**: Include test descriptions and expected outcomes
5. **Verify cross-template support**: Ensure tests work with both GetX and Clean templates

## Performance Guidelines

- Tests should complete within 30 seconds per individual test
- Use `OptimizedTestManager` for template reuse
- Clean up resources in `tearDown` blocks
- Monitor execution times and optimize slow tests

## Debugging

To debug test failures:

```bash
# Enable detailed stack traces
dart test test/e2e/controller_command_test.dart --chain-stack-traces

# Run specific test with verbose output
dart test test/e2e/controller_command_test.dart --name "should create shared controller"
```