## 0.1.2

- **🔧 pub.dev Compliance** - Fixed topics count to meet pub.dev's 5-topic limit requirement
- **📝 Topic Optimization** - Refined package topics to focus on core functionality (cli, flutter, getx, clean-architecture, code-generation)

## 0.1.1

- **🎨 Asset Reorganization** - Simplified asset naming convention for improved maintainability
- **📦 pub.dev Optimization** - Enhanced package description, updated dependencies, and added platform support declarations  
- **🖼️ New Asset Structure** - Replaced complex asset names with clean, intuitive naming:
  - `logo.svg` - Primary brand logo
  - `logo-black.svg` / `logo-white.svg` - Theme-specific variants
  - `logo.png` - PNG version for pub.dev screenshots
  - `gexd-cli-logo.svg` - CLI-specific branding
- **📝 Documentation Updates** - Updated all asset references across documentation, GitBook, and configuration files
- **🗑️ Legacy Cleanup** - Removed outdated asset files and references for cleaner repository structure
- **🏗️ GitBook Integration** - Updated logo configuration for better theme compatibility
- **📊 pub.dev Score Improvement** - Enhanced package metadata and compliance for better discoverability

## 0.1.0

- **🏗️ Architecture Consistency** - Unified naming from "translations" to "locales" across all templates and components
- **🧪 E2E Test Stability** - Fixed all E2E tests for widget, interface, and locale commands
- **📚 Documentation Improvements** - Simplified examples and updated all asset paths
- **🌐 Locale Path Consistency** - Updated all examples
- **✅ Model Command Fixes** - Fixed broken URL test by replacing unreliable endpoint with jsonplaceholder
- **📖 README Enhancements** - Comprehensive documentation updates with consistent examples and paths

## 0.0.3

- **NEW: Entity Command** - Generate domain entities for Clean Architecture with multiple styles and JSON conversion support
- **NEW: Util Command** - Generate utility helper classes with customizable templates and subdirectory support
- **NEW: Widget Command** - Generate reusable Flutter widgets with location flexibility (shared/screen) and subdirectory support
- **🔧 Fixed File Formatting** - Resolved formatting issues across all make commands for consistent code generation
- **Enhanced Path Management** - Improved component registry with proper path resolution for all templates
- **Architecture Support** - Full GetX and Clean Architecture compatibility for all new commands

## 0.0.2

- **NEW: Typed Model Support** - Added --model option to Repository and Interface commands for typed method generation
- **NEW: Interface Command** - Create interface components with full model integration support  
- **NEW: Provider Command** - Generate provider components with consistent architecture patterns
- **NEW: Repository Command** - Enhanced repository generation with typed/dynamic method support
- **Enhanced Model Detection** - Improved model validation and import path generation across different architectures
- **Template System Updates** - Conditional typing in Mason bricks with typed vs dynamic method variants
- **Architecture Support** - Full compatibility with both GetX and Clean Architecture templates
- **Import Path Generation** - Centralized import handling using ArchitectureCoordinator
- **File Management** - Enhanced file reporting and formatting with unified interface handling
- Added ViewCommand for creating view components
- Enhanced PostGenerationService with formatSpecificFiles method for better performance
- Improved ArchitectureCoordinator for consistent path resolution
- Added comprehensive E2E tests for ViewCommand
- Fixed binding job path consistency issues
- Updated all job files use ArchitectureCoordinator instead of hard-coded paths
- Performance improvements: 50-60% faster formatting by targeting only generated files
- Code cleanup: removed unused StringExtension from test files

## 0.0.1

- Initial version.
