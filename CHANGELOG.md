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
