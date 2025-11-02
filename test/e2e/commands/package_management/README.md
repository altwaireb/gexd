# Package Management E2E Tests

This directory contains comprehensive end-to-end tests for all package management commands in the gexd CLI tool.

## 📦 Commands Tested

### 1. AddCommand (`gexd add`)
**File:** `add_command_test.dart`

Tests package addition functionality with full `flutter pub add` wrapper support.

**Features Covered:**
- ✅ Basic package addition with validation
- ✅ Development dependencies (`--dev`)
- ✅ Version constraints and quoted arguments
- ✅ Offline/online modes (`--offline`, `--no-offline`)
- ✅ Precompile options (`--precompile`, `--no-precompile`)
- ✅ Dry-run mode (`--dry-run`)
- ✅ Advanced package types (git, path, hosted)
- ✅ Template compatibility (GetX, Clean)
- ✅ Error handling and validation
- ✅ Command output validation

### 2. RemoveCommand (`gexd remove`)
**File:** `remove_command_test.dart`

Tests package removal functionality with `flutter pub remove` integration.

**Features Covered:**
- ✅ Single and multiple package removal
- ✅ Override dependencies (`override:package_name`)
- ✅ Dry-run mode functionality
- ✅ Offline mode support
- ✅ Precompile options
- ✅ Template compatibility
- ✅ Error handling for non-existent packages
- ✅ Progress messages and output validation

### 3. UpgradeCommand (`gexd upgrade`)
**File:** `upgrade_command_test.dart`

Tests advanced package upgrade functionality with multiple modes.

**Features Covered:**
- ✅ Basic package upgrades (all or specific)
- ✅ Major version upgrades (`--major-versions`)
- ✅ Dependency tightening (`--tighten`)
- ✅ Transitive dependency unlocking (`--unlock-transitive`)
- ✅ Combined advanced flags
- ✅ Dry-run mode functionality
- ✅ Offline mode support
- ✅ Smart upgrade tips and warnings
- ✅ Template compatibility
- ✅ Error handling and validation

### 4. SelfUpdateCommand (`gexd self-update`)
**File:** `self_update_command_test.dart`

Tests CLI tool self-updating functionality with pub_updater integration.

**Features Covered:**
- ✅ Version checking with pub_updater
- ✅ Dry-run mode for preview updates
- ✅ Configuration file updates
- ✅ Network connectivity handling
- ✅ Template independence (works from any directory)
- ✅ Update preview and progress messages
- ✅ Error handling for network issues
- ✅ Version information display

## 🚀 Running Tests

### Run Specific Command Tests
```bash
# Add command tests
dart test test/e2e/commands/package_management/add_command_test.dart

# Remove command tests
dart test test/e2e/commands/package_management/remove_command_test.dart

# Upgrade command tests
dart test test/e2e/commands/package_management/upgrade_command_test.dart

# Self-update command tests
dart test test/e2e/commands/package_management/self_update_command_test.dart
```

### Run with Tags
```bash
# Run all E2E tests
dart test --tags e2e

# Run with verbose output
dart test --tags e2e --reporter expanded
```

## 🏗️ Test Structure

Each test file follows a consistent comprehensive structure:

1. **📋 Pre-conditions & Validation**
   - Project validation checks
   - Help documentation verification
   - Input validation tests

2. **📦 Basic Operations**
   - Core functionality testing
   - Standard use cases
   - Dry-run mode validation

3. **🎛️ Advanced Features & Flags**
   - All command-line options
   - Flag combinations
   - Advanced functionality

4. **🏗️ Template Compatibility**
   - GetX template compatibility
   - Clean template compatibility
   - Cross-template validation

5. **⚠️ Error Handling**
   - Network issues
   - Invalid inputs
   - Edge cases

6. **📝 Command Output Validation**
   - Progress messages
   - Success/error outputs
   - Help text validation

## ⚡ Performance Optimization

All tests use the `OptimizedTestManager` for:
- 🚀 Fast test execution with caching
- 📁 Optimized project creation
- 🧹 Automatic cleanup
- 💾 Resource management

## 🧪 Test Coverage

Each command test provides comprehensive coverage including:

- **Validation:** Pre-conditions, input validation, project checks
- **Core Functionality:** All main features and use cases
- **Options & Flags:** Every command-line option and combination
- **Error Scenarios:** Network issues, invalid inputs, edge cases
- **Output Validation:** Messages, formatting, help text
- **Compatibility:** All project templates and environments

## 📊 Test Results

Tests provide detailed feedback with:
- ✅ Success indicators for each test group
- ⚡ Performance timing information
- 🎯 Specific validation results
- 📝 Clear error messages when issues occur

## 🔧 Maintenance

These tests are designed to be:
- **Maintainable:** Clear structure and documentation
- **Reliable:** Consistent patterns and error handling
- **Extensible:** Easy to add new test cases
- **Fast:** Optimized execution with resource management

## 🤝 Contributing

When adding new package management features:

1. Follow the existing test structure
2. Add comprehensive test coverage
3. Include error handling scenarios
4. Test template compatibility
5. Validate command output
6. Update this README

---

**Note:** These E2E tests complement the existing unit tests and provide full integration testing for the complete package management suite in gexd.