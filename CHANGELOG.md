## 0.1.11

- **🔧 Template Validation & Recovery** - Enhanced template content validation and automatic correction for both create and init commands0.1.11

- **� Template Validation & Recovery** - Enhanced template content validation and automatic correction for both create and init commands
- **📝 Complete Variable Support** - Added missing template variables and improved Mason generation reliability
- **✅ Bulletproof File Generation** - Guaranteed creation of .gexd/config.yaml and test/widget_test.dart with correct content

## 0.1.10

- **🔧 Enhanced Error Handling** - Added fallback mechanisms to create missing template files (.gexd/config.yaml, test/widget_test.dart) when Mason generation fails
- **🛠️ Automatic File Recovery** - Template files are now created manually with proper content if Mason brick generation is incomplete  
- **📝 Improved Variable Processing** - Fixed unprocessed Mason variables with automatic replacement fallback
- **🔍 Better Debugging** - Enhanced logging to show exactly which files are created vs recovered manually

## 0.1.9

- **✅ Template Variable Processing** - Fixed complete Mason template variable resolution in generated projects
- **🎯 Enhanced Template Files** - Ensured all template files (.gexd/config.yaml, test/widget_test.dart) are properly generated with processed variables
- **📊 Added Template Variables** - Added missing `generated_date` variable to CreateData.toVars() for complete template support
- **🔍 Improved Debugging** - Enhanced logging and verification for template file generation

## 0.1.8

- **🔧 Critical Fix** - Enhanced package root detection to properly locate Mason bricks in published packages
- **🎯 Brick Discovery** - Fixed "Brick not found" error by improving pub-cache and global package path resolution
- **📦 Robust Path Resolution** - Added multiple fallback methods to ensure bricks are found in all installation scenarios

## 0.1.7

- **🔧 GitHub Actions Fix** - Updated dart-lang/setup-dart to correct version v1.7.1 to resolve CI/CD pipeline errors
- **⚡ CI/CD Stability** - Fixed workflow execution issues that were preventing successful releases

## 0.1.6

- **🚀 Mason Templates Included** - Moved bricks to assets/bricks/ to ensure templates are included in published package
- **🔧 Enhanced Path Resolution** - Improved MasonService to support both development (tool/bricks/) and published (assets/bricks/) locations
- **📦 Package Optimization** - Fixed pub.dev validation issues while maintaining full functionality (204KB)

## 0.1.5

- **🚀 Architecture Optimization** - Organized Mason bricks in `tool/bricks/` for cleaner package structure
- **⚡ Performance Enhancement** - Reduced package size by 21% (162KB) with improved efficiency
- **🛡️ Enhanced Reliability** - Improved MasonService with robust path resolution

## 0.1.4

- **🔧 Critical Fix** - Move bricks to `lib/src/bricks/` to ensure they are included in published package
- **📦 Template Accessibility** - Fix "Brick not found" error when using `dart pub global activate gexd`
- **⚡ Improved Path Resolution** - Enhanced Mason service with fallback path resolution for better reliability

## 0.1.3

- **🔧 Package Assets** - Include Mason bricks in published package for template functionality
- **📦 Template Support** - Ensure all project templates work correctly after global installation

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
