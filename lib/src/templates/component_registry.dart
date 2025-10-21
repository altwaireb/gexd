// ComponentRegistry — maps NameComponent -> ComponentMetadata
// Focused on two templates: ProjectTemplate.getx and ProjectTemplate.clean.

import 'package:gexd/src/core/enums/project_template.dart';
import 'package:meta/meta.dart';

import 'component_metadata.dart';
import '../core/enums/name_component.dart';
import 'architecture_template.dart';

@immutable
class ComponentRegistry {
  ComponentRegistry._();

  static final Map<NameComponent, ComponentMetadata> _registry = {
    // ================= Core =================
    NameComponent.core: ComponentMetadata(
      description: 'Core application foundation',
      category: 'core',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxAppCore,
        ProjectTemplate.clean: ArchitectureTemplate.cleanCore,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.coreBindings: ComponentMetadata(
      description: 'Initial dependency bindings',
      category: 'core',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxAppCoreBindings,
        ProjectTemplate.clean: ArchitectureTemplate.cleanCoreBindings,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.coreThemes: ComponentMetadata(
      description: 'App theme definitions',
      category: 'core',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxAppCoreThemes,
        ProjectTemplate.clean: ArchitectureTemplate.cleanCoreThemes,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.coreUtils: ComponentMetadata(
      description: 'Utility functions and helpers',
      category: 'core',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxAppCoreUtils,
        ProjectTemplate.clean: ArchitectureTemplate.cleanCoreUtils,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.coreConstants: ComponentMetadata(
      description: 'Constant values',
      category: 'core',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxAppCoreConstants,
        ProjectTemplate.clean: ArchitectureTemplate.cleanCoreConstants,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.coreMiddleware: ComponentMetadata(
      description: 'Middleware for requests and routing',
      category: 'core',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxAppCoreMiddleware,
        ProjectTemplate.clean: ArchitectureTemplate.cleanCoreMiddleware,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.coreExtensions: ComponentMetadata(
      description: 'Extensions for Dart core types',
      category: 'core',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxAppCoreExtensions,
        ProjectTemplate.clean: ArchitectureTemplate.cleanCoreExtensions,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),

    // ================= Data Layer =================
    NameComponent.models: ComponentMetadata(
      description: 'Data models',
      category: 'data',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxDataModels,
        ProjectTemplate.clean: ArchitectureTemplate.cleanInfrastructureModels,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.entities: ComponentMetadata(
      description: 'Entities representing core domain objects',
      category: 'data',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxDataEntities,
        ProjectTemplate.clean: ArchitectureTemplate.cleanDomainEntities,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.repositories: ComponentMetadata(
      description: 'Repository interfaces and implementations',
      category: 'data',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxDataRepositories,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanInfrastructureRepositories,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.repositoriesInterfaces: ComponentMetadata(
      description: 'Repository interfaces',
      category: 'data',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx:
            ArchitectureTemplate.getxDataRepositoriesInterfaces,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanInfrastructureRepositoriesInterfaces,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.services: ComponentMetadata(
      description: 'Application services',
      category: 'data',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxDataServices,
        ProjectTemplate.clean: ArchitectureTemplate.cleanInfrastructureServices,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.servicesInterfaces: ComponentMetadata(
      description: 'Service interfaces',
      category: 'data',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxDataServicesInterfaces,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanInfrastructureServicesInterfaces,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.datasources: ComponentMetadata(
      description: 'Data sources',
      category: 'data',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxDataDatasources,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanInfrastructureDatasources,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: false},
    ),
    NameComponent.datasourcesInterfaces: ComponentMetadata(
      description: 'Data sources interfaces',
      category: 'data',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx:
            ArchitectureTemplate.getxDataRemoteDatasourcesInterfaces,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanInfrastructureDatasourcesInterfaces,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: false},
    ),
    NameComponent.localDatasources: ComponentMetadata(
      description: 'Local datasources (DB, cache)',
      category: 'data',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxDataLocalDatasources,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanInfrastructureLocalDatasources,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.remoteDatasources: ComponentMetadata(
      description: 'Remote datasources (API)',
      category: 'data',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxDataRemoteDatasources,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanInfrastructureRemoteDatasources,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),

    // ================= Domain Layer =================
    NameComponent.usecases: ComponentMetadata(
      description: 'Usecases / business rules',
      category: 'domain',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxDomainUsecases,
        ProjectTemplate.clean: ArchitectureTemplate.cleanDomainUsecases,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.usecasesInterfaces: ComponentMetadata(
      description: 'Usecases / business rules interfaces',
      category: 'domain',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxDomainUsecasesInterfaces,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanDomainUsecasesInterfaces,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),

    // ================= Screens / UI =================
    NameComponent.screen: ComponentMetadata(
      description: 'Application screens',
      category: 'presentation',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxModules,
        ProjectTemplate.clean: ArchitectureTemplate.cleanPresentationPages,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.screenControllers: ComponentMetadata(
      description: 'Screen controllers',
      category: 'presentation',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxModulesControllers,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanPresentationPagesControllers,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.screenViews: ComponentMetadata(
      description: 'Screen views',
      category: 'presentation',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxModulesViews,
        ProjectTemplate.clean: ArchitectureTemplate.cleanPresentationPagesViews,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.screenWidgets: ComponentMetadata(
      description: 'Screen widgets',
      category: 'presentation',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxModulesWidgets,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanPresentationPagesWidgets,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.screenBindings: ComponentMetadata(
      description: 'Screen bindings',
      category: 'presentation',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxModulesBindings,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanPresentationPagesBindings,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.screenErrors: ComponentMetadata(
      description: 'Error screens root folder',
      category: 'presentation',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxModulesErrors,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanPresentationPagesErrors,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    // setup screen
    NameComponent.screenHome: ComponentMetadata(
      description: 'Home screens',
      category: 'presentation',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxModulesHome,
        ProjectTemplate.clean: ArchitectureTemplate.cleanPresentationPagesHome,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.screenErrorsNotFound: ComponentMetadata(
      description: 'Not found screens',
      category: 'presentation',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxModulesErrorsNotFound,
        ProjectTemplate.clean:
            ArchitectureTemplate.cleanPresentationPagesErrorsNotFound,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),

    // ================= Navigation =================
    NameComponent.routes: ComponentMetadata(
      description: 'Navigation routes',
      category: 'navigation',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxRoutes,
        ProjectTemplate.clean: ArchitectureTemplate.cleanPresentationRoutes,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.bindings: ComponentMetadata(
      description: 'Shared bindings folder',
      category: 'navigation',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxModulesBindings,
        ProjectTemplate.clean: ArchitectureTemplate.cleanPresentationBindings,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),

    // ================= Shared =================
    NameComponent.widgets: ComponentMetadata(
      description: 'Shared widgets',
      category: 'ui',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxSharedWidgets,
        ProjectTemplate.clean: ArchitectureTemplate.cleanSharedWidgets,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.components: ComponentMetadata(
      description: 'Shared components',
      category: 'ui',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxSharedComponents,
        ProjectTemplate.clean: ArchitectureTemplate.cleanSharedComponents,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.translations: ComponentMetadata(
      description: 'Translation and internationalization files',
      category: 'core',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.getxTranslations,
        ProjectTemplate.clean: ArchitectureTemplate.cleanTranslations,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.test: ComponentMetadata(
      description: 'Test components',
      category: 'ui',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.test,
        ProjectTemplate.clean: ArchitectureTemplate.test,
      },
      isEssential: {ProjectTemplate.getx: true, ProjectTemplate.clean: true},
    ),
    NameComponent.testWidgets: ComponentMetadata(
      description: 'Test widgets components',
      category: 'ui',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.testWidgets,
        ProjectTemplate.clean: ArchitectureTemplate.testWidgets,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.testBindings: ComponentMetadata(
      description: 'Test bindings components',
      category: 'ui',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.testBindings,
        ProjectTemplate.clean: ArchitectureTemplate.testBindings,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
    NameComponent.testErrors: ComponentMetadata(
      description: 'Test errors components',
      category: 'ui',
      supportedTemplates: {ProjectTemplate.getx, ProjectTemplate.clean},
      defaultPath: {
        ProjectTemplate.getx: ArchitectureTemplate.testErrors,
        ProjectTemplate.clean: ArchitectureTemplate.testErrors,
      },
      isEssential: {ProjectTemplate.getx: false, ProjectTemplate.clean: false},
    ),
  };

  /// Get metadata for a specific component
  static ComponentMetadata? get(NameComponent component) =>
      _registry[component];

  /// Get all supported components for a specific template
  static List<NameComponent> getComponentsForTemplate(
    ProjectTemplate template, {
    bool onlyEssential = false,
  }) {
    return _registry.entries
        .where((entry) => entry.value.supportedTemplates.contains(template))
        .where(
          (entry) =>
              !onlyEssential || (entry.value.isEssential[template] ?? false),
        )
        .map((entry) => entry.key)
        .toList();
  }

  /// Check if the component is supported for a specific template
  static bool isSupported(NameComponent component, ProjectTemplate template) {
    final metadata = _registry[component];
    return metadata?.supportedTemplates.contains(template) ?? false;
  }

  /// Check if a component is essential for a given template
  static bool isEssential(NameComponent component, ProjectTemplate template) {
    final metadata = _registry[component];
    return metadata?.isEssential[template] ?? false;
  }

  /// Get default path for a component and template (may return null)
  static String? getPath(NameComponent component, ProjectTemplate template) {
    final metadata = _registry[component];
    return metadata?.defaultPath[template];
  }
}
