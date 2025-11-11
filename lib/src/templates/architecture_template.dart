/// 🏗️ Architecture Template Definitions
///
/// This class defines the complete directory structure and file organization
/// for each project template type in Gexd CLI.
///
/// Supports three main architecture patterns:
/// - GetX Template: Feature-based modular architecture with GetX state management
/// - Clean Architecture Template: Domain-driven design with clear layer separation
class ArchitectureTemplate {
  ArchitectureTemplate._();

  // ============================================================================
  // 🎯 GETX TEMPLATE ARCHITECTURE
  // ============================================================================

  /// GetX Template - Feature-based modular architecture
  ///
  /// This structure organizes code by features/modules, where each module
  /// contains its own controllers, views, bindings, and related files.
  /// Perfect for medium to large applications using GetX state management.

  // Core Application Structure
  static const String getxAppCore = 'lib/app/core';
  static const String getxAppCoreBindings = 'lib/app/core/bindings';
  static const String getxAppCoreThemes = 'lib/app/core/themes';
  static const String getxAppCoreUtils = 'lib/app/core/utils';
  static const String getxAppCoreMiddleware = 'lib/app/core/middleware';
  static const String getxAppCoreConstants = 'lib/app/core/constants';
  static const String getxAppCoreExtensions = 'lib/app/core/extensions';
  static const String getxAppCoreExceptions = 'lib/app/core/exceptions';

  // Data Layer Structure
  static const String getxDataLayer = 'lib/app/data';
  static const String getxDataModels = 'lib/app/data/models';
  static const String getxDataEntities = 'lib/app/data/entities';
  static const String getxDataRepositories = 'lib/app/data/repositories';
  static const String getxDataRepositoriesInterfaces =
      'lib/app/data/repositories/interfaces';
  static const String getxDataInterfaces = 'lib/app/data/interfaces';
  static const String getxDataServices = 'lib/app/data/services';
  static const String getxDataProviders = 'lib/app/data/providers';
  static const String getxDataDatasources = 'lib/app/data/datasources';
  static const String getxDataRemoteDatasourcesInterfaces =
      'lib/app/data/datasources/interfaces';
  static const String getxDataLocalDatasources =
      'lib/app/data/datasources/local';
  static const String getxDataRemoteDatasources =
      'lib/app/data/datasources/remote';

  // Business Logic Layer
  static const String getxDomainLayer = 'lib/app/domain';
  static const String getxDomainUsecases = 'lib/app/domain/usecases';
  static const String getxDomainEntities = 'lib/app/domain/entities';
  static const String getxDomainRepositories = 'lib/app/domain/repositories';

  // Modules/Features Structure - Enhanced with proper subfolder organization
  static const String getxModules = 'lib/app/modules';
  static const String getxModulesShared = 'lib/app/modules/shared';
  static const String getxModulesControllers = 'lib/app/modules/controllers';
  static const String getxModulesViews = 'lib/app/modules/views';
  static const String getxModulesBindings = 'lib/app/modules/bindings';
  static const String getxModulesWidgets = 'lib/app/modules/widgets';

  // Error Module Structure
  static const String getxModulesErrors = 'lib/app/modules/errors';

  // setup Modules screen
  static const String getxModulesHome = 'lib/app/modules/home';
  static const String getxModulesErrorsNotFound =
      'lib/app/modules/errors/not_found';

  // Navigation and Routing
  static const String getxRoutes = 'lib/app/routes';
  // static const String getxRoutesPages = 'lib/app/routes/pages';
  static const String getxRoutesMiddleware = 'lib/app/routes/middleware';

  // Shared Widgets and Components
  static const String getxSharedWidgets = 'lib/app/shared/widgets';
  static const String getxSharedComponents = 'lib/app/shared/components';

  // Translations and Internationalization
  static const String getxTranslations = 'lib/app/locales';

  // ============================================================================
  // 🏛️ CLEAN ARCHITECTURE TEMPLATE
  // ============================================================================

  /// Clean Architecture Template - Domain-driven design with clear layer separation
  ///
  /// This structure follows Uncle Bob's Clean Architecture principles,
  /// separating code into distinct layers with clear dependencies.
  /// Perfect for large, complex applications requiring high maintainability.

  // Core Layer - Framework independent
  static const String cleanCore = 'lib/core';
  static const String cleanCoreBindings = 'lib/core/bindings';
  static const String cleanCoreThemes = 'lib/core/themes';
  static const String cleanCoreUtils = 'lib/core/utils';
  static const String cleanCoreConstants = 'lib/core/constants';
  static const String cleanCoreExtensions = 'lib/core/extensions';
  static const String cleanCoreMiddleware = 'lib/core/middleware';
  static const String cleanCoreErrors = 'lib/core/errors';
  static const String cleanCoreUsecases = 'lib/core/usecases';
  static const String cleanCoreExceptions = 'lib/core/exceptions';

  // Domain Layer - Business Logic
  static const String cleanDomain = 'lib/domain';
  static const String cleanDomainEntities = 'lib/domain/entities';
  static const String cleanInterfaces = 'lib/domain/interfaces';
  static const String cleanDomainRepositories = 'lib/domain/repositories';
  static const String cleanDomainUsecases = 'lib/domain/usecases';
  static const String cleanDomainModels = 'lib/domain/models';
  static const String cleanDomainValueObjects = 'lib/domain/value_objects';
  static const String cleanDomainFailures = 'lib/domain/failures';

  // Infrastructure Layer - External Dependencies
  static const String cleanInfrastructure = 'lib/infrastructure';
  static const String cleanInfrastructureModels = 'lib/infrastructure/models';
  static const String cleanInfrastructureProviders =
      'lib/infrastructure/providers';
  static const String cleanInfrastructureRepositories =
      'lib/infrastructure/repositories';
  static const String cleanInfrastructureRepositoriesInterfaces =
      'lib/infrastructure/repositories/interfaces';
  static const String cleanInfrastructureServices =
      'lib/infrastructure/services';
  static const String cleanInfrastructureDatasources =
      'lib/infrastructure/datasources';
  static const String cleanInfrastructureDatasourcesInterfaces =
      'lib/infrastructure/datasources/interfaces';
  static const String cleanInfrastructureLocalDatasources =
      'lib/infrastructure/datasources/local';
  static const String cleanInfrastructureRemoteDatasources =
      'lib/infrastructure/datasources/remote';
  static const String cleanInfrastructureNetworking =
      'lib/infrastructure/networking';

  // Presentation Layer - UI and State Management
  static const String cleanPresentation = 'lib/presentation';
  static const String cleanPresentationControllers =
      'lib/presentation/controllers';
  static const String cleanPresentationViews = 'lib/presentation/views';
  static const String cleanPresentationWidgets = 'lib/presentation/widgets';
  static const String cleanPresentationBindings = 'lib/presentation/bindings';
  static const String cleanPresentationRoutes = 'lib/presentation/routes';
  static const String cleanPresentationMiddleware =
      'lib/presentation/middleware';

  // Feature-based organization within presentation - Enhanced structure
  static const String cleanPresentationPages = 'lib/presentation/pages';

  static const String cleanPresentationPagesControllers =
      'lib/presentation/pages/controllers';
  static const String cleanPresentationPagesViews =
      'lib/presentation/pages/views';
  static const String cleanPresentationPagesBindings =
      'lib/presentation/pages/bindings';
  static const String cleanPresentationPagesWidgets =
      'lib/presentation/pages/widgets';

  // Error Page Structure
  static const String cleanPresentationPagesErrors =
      'lib/presentation/pages/errors';

  // setup screen
  static const String cleanPresentationPagesHome =
      'lib/presentation/pages/home';
  static const String cleanPresentationPagesErrorsNotFound =
      'lib/presentation/pages/errors/not_found';

  // Shared Components
  static const String cleanShared = 'lib/shared';
  static const String cleanSharedWidgets = 'lib/shared/widgets';
  static const String cleanSharedUtils = 'lib/shared/utils';
  static const String cleanSharedConstants = 'lib/shared/constants';
  static const String cleanSharedComponents = 'lib/shared/components';

  // Translations and Internationalization
  static const String cleanTranslations = 'lib/locales';

  // Test
  static const String test = 'test';
  static const String testWidgets = 'test/widgets';
  static const String testBindings = 'test/bindings';
  static const String testErrors = 'test/errors';
}
