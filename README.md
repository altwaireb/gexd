# Gexd CLI

[![Format & Analyze](https://github.com/altwaireb/gexd/actions/workflows/formatting-analyze.yml/badge.svg)](https://github.com/altwaireb/gexd/actions/workflows/formatting-analyze.yml)
[![Run Tests](https://github.com/altwaireb/gexd/actions/workflows/run-tests.yml/badge.svg)](https://github.com/altwaireb/gexd/actions/workflows/run-tests.yml)
[![E2E Tests](https://github.com/altwaireb/gexd/actions/workflows/e2e-tests.yml/badge.svg)](https://github.com/altwaireb/gexd/actions/workflows/e2e-tests.yml)
[![Release](https://github.com/altwaireb/gexd/actions/workflows/release.yml/badge.svg)](https://github.com/altwaireb/gexd/actions/workflows/release.yml)
[![Latest Release](https://img.shields.io/github/v/release/altwaireb/gexd)](https://github.com/altwaireb/gexd/releases/latest)
[![codecov](https://codecov.io/gh/altwaireb/gexd/branch/main/graph/badge.svg)](https://codecov.io/gh/altwaireb/gexd)
[![pub package](https://img.shields.io/pub/v/gexd.svg)](https://pub.dev/packages/gexd)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful command-line tool for generating Flutter projects with GetX and Clean Architecture templates.

## 📦 Installation & Download

### 🚀 Quick Install (Recommended)
```bash
# Install from pub.dev
dart pub global activate gexd

# Verify installation
gexd --version
```

### 💾 Download Pre-built Binaries

Get the latest release for your platform:

| Platform | Download | Status |
|----------|----------|---------|
| 🐧 **Linux (x64)** | [📥 gexd-linux-x64](https://github.com/altwaireb/gexd/releases/latest/download/gexd-linux-x64) | ✅ Ready |
| 🪟 **Windows (x64)** | [📥 gexd-windows-x64.exe](https://github.com/altwaireb/gexd/releases/latest/download/gexd-windows-x64.exe) | ✅ Ready |
| 🍎 **macOS (Intel)** | [📥 gexd-macos-x64](https://github.com/altwaireb/gexd/releases/latest/download/gexd-macos-x64) | ✅ Ready |
| 🍎 **macOS (Apple Silicon)** | [📥 gexd-macos-arm64](https://github.com/altwaireb/gexd/releases/latest/download/gexd-macos-arm64) | ✅ Ready |

> 🔗 **All Releases:** [GitHub Releases Page](https://github.com/altwaireb/gexd/releases)

### 🔐 Verify Downloads
```bash
# Download checksums file
curl -LO https://github.com/altwaireb/gexd/releases/latest/download/checksums.txt

# Verify your download (example for Linux)
sha256sum -c checksums.txt --ignore-missing
```

## 🚀 Quick Start

### Create Your First Project
```bash
# Create a new GetX project
gexd create my_awesome_app

# Or create with Clean Architecture
gexd create my_app --template clean

# Navigate to your project
cd my_awesome_app

# Start developing!
flutter run
```

### Generate Components
```bash
# Generate a new screen
gexd make screen user_profile

# Generate a service
gexd make service api_service

# Generate a model with custom fields
gexd make model user --interactive

# Generate a controller
gexd make controller home_controller
```

### Get Help
```bash
# Show all commands
gexd --help

# Get help for specific command
gexd make --help
gexd create --help
```

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

## 🚢 Release Process

### Creating a New Release
```bash
# 1. Update version in pubspec.yaml
# 2. Update CHANGELOG.md
# 3. Commit changes
git add .
git commit -m "chore: bump version to v1.2.3"

# 4. Create and push tag
git tag v1.2.3
git push origin v1.2.3
```

### 🤖 Automated Release Pipeline
The release process is fully automated via GitHub Actions:

1. **🏗️ Multi-Platform Build:** Linux, Windows, macOS (Intel + Apple Silicon)
2. **🧪 Safety Tests:** Unit tests run before building
3. **📦 Artifacts:** Compiled binaries with checksums  
4. **📝 Release Notes:** Auto-generated from commits
5. **🌍 Distribution:** GitHub Releases + pub.dev (when ready)

### 📊 CI/CD Overview

| Workflow | Trigger | Purpose | Duration |
|----------|---------|---------|----------|
| 🎨 **Format & Analyze** | Feature branches | Code quality checks | ~5min |
| ✅ **Run Tests** | Pull requests | Unit & build tests | ~15min |
| 🚀 **E2E Tests** | Manual + Release tags | Comprehensive testing | ~25min |
| 📦 **Release** | Version tags | Multi-platform build & publish | ~20min |
| 🤖 **Dependabot** | Weekly | Dependency updates | ~5min |

> 💡 **Resource Optimization:** Our CI system saves ~92% of GitHub Actions minutes through smart triggering and caching.

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### 🐛 Report Issues
- 🔗 [Create an Issue](https://github.com/altwaireb/gexd/issues/new)
- 💡 [Feature Requests](https://github.com/altwaireb/gexd/discussions/new?category=ideas)
- ❓ [Ask Questions](https://github.com/altwaireb/gexd/discussions/new?category=q-a)

### 💻 Development Setup
```bash
# Clone the repository
git clone https://github.com/altwaireb/gexd.git
cd gexd

# Setup development environment
make setup

# Run tests
make test

# Create a feature branch
git checkout -b feature/awesome-feature
```

### 📋 Development Guidelines
- ✅ Follow the existing code style
- 🧪 Add tests for new features  
- 📝 Update documentation
- 🎯 Keep commits focused and descriptive

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- 🌟 **GetX Team** - For the amazing state management solution
- 🚀 **Flutter Team** - For the incredible framework
- 💙 **Dart Community** - For continuous inspiration
- 🤝 **Contributors** - For making this project better

---

<div align="center">

**⭐ Star this project if you find it helpful!**

[🏠 Home](https://github.com/altwaireb/gexd) • [📖 Docs](./doc/1.x/README.md) • [🐛 Issues](https://github.com/altwaireb/gexd/issues) • [💬 Discussions](https://github.com/altwaireb/gexd/discussions)

</div>
