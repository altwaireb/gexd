## 0.0.3

- **🚀 NEW: Entity Command** - Generate domain entities for Clean Architecture with multiple styles (plain, immutable, freezed)
- **🔄 Advanced Entity Generation** - Support for JSON-to-Entity conversion with automatic model generation using `--with-model` flag
- **🎯 Entity Style System** - Choose between plain, immutable, or freezed entity styles with proper dependency management
- **🌐 Multi-Source Entity Creation** - Generate entities from templates, JSON files, or API endpoints
- **🏗️ Enhanced Clean Architecture Support** - Domain entity generation with proper folder structure and imports
- **📚 Comprehensive Documentation** - Added complete example directory with advanced localization features
- **🔧 Improved Development Experience** - Better error handling, validation, and user guidance for entity workflows

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
