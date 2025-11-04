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
- Updated all job files to use ArchitectureCoordinator instead of hard-coded paths
- Performance improvements: 50-60% faster formatting by targeting only generated files
- Code cleanup: removed unused StringExtension from test files

## 0.0.1

- Initial version.
