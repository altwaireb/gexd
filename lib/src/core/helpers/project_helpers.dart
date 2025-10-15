/// 🚀 Project Helpers - Centralized project utilities
///
/// This class provides a simplified, centralized API for common project operations
/// including configuration access, template management, and path resolution.
library;

import 'package:gexd/gexd.dart';

/// Central helper class for project-related operations
///
/// Provides simplified access to:
/// - Project configuration (name, template)
/// - Component path resolution
/// - Template validation
/// - Project structure queries
class ProjectHelpers {
  ProjectHelpers._();

  static Future<ProjectData?> getdata() async {
    final String? name = await getName();
    final ProjectTemplate? template = await getTemplateOrNull();
    if (name == null || template == null) return null;

    return ProjectData(name: name, template: template);
  }

  // ======================== PROJECT INFO ========================

  /// Get current project name from config
  /// Returns null if not in Gexd project or config not found
  static Future<String?> getName() async {
    return await ConfigService.getProjectName();
  }

  /// Get current project template from config
  /// Throws ValidationException if template not found or invalid project
  static Future<ProjectTemplate> getTemplate() async {
    final template = await ConfigService.getProjectTemplate();
    if (template == null) {
      throw ValidationException.invalidFormat(
        'template',
        'Could not detect project template',
        expectedFormat: 'A valid Gexd project template',
      );
    }
    return template;
  }

  /// Get current project template from config (nullable version)
  /// Returns null if not in Gexd project or template not found
  static Future<ProjectTemplate?> getTemplateOrNull() async {
    return await ConfigService.getProjectTemplate();
  }

  /// Get project root directory path
  /// Returns null if not in Gexd project
  static Future<String?> getRoot() async {
    return await ConfigService.getProjectRoot();
  }

  /// Check if current directory is a Gexd project
  static Future<bool> isInGexdProject() async {
    return await ConfigService.isInGexdProject();
  }

  // ======================== PATH HELPERS ========================

  /// Get component path for current project template
  /// Returns empty string if not in Gexd project or component not supported
  static Future<String> getComponentPath(NameComponent component) async {
    final template = await getTemplateOrNull();
    if (template == null) return '';

    return ComponentRegistry.getPath(component, template) ?? '';
  }

  /// Get component path without 'lib/' prefix for current project
  /// Useful for package imports
  static Future<String> getComponentPathWithoutLib(
    NameComponent component,
  ) async {
    final fullPath = await getComponentPath(component);
    if (fullPath.startsWith('lib/')) {
      return fullPath.substring(4); // Remove 'lib/' prefix
    }
    return fullPath;
  }

  /// Get component path for specific template
  /// Returns empty string if component not supported for template
  static String getComponentPathForTemplate(
    NameComponent component,
    ProjectTemplate template,
  ) {
    return ComponentRegistry.getPath(component, template) ?? '';
  }

  /// Get all directory paths for current project template
  /// If full == false, returns only essential components
  static Future<List<String>> getDirectories({bool full = false}) async {
    final template = await getTemplateOrNull();
    if (template == null) return [];

    final components = ComponentRegistry.getComponentsForTemplate(
      template,
      onlyEssential: !full,
    );

    final paths = <String>[];
    for (final comp in components) {
      final path = ComponentRegistry.getPath(comp, template);
      if (path != null && path.isNotEmpty) {
        paths.add(path);
      }
    }
    return paths;
  }

  // ======================== VALIDATION ========================

  /// Check if component is supported in current project
  static Future<bool> isComponentSupported(NameComponent component) async {
    final template = await getTemplateOrNull();
    if (template == null) return false;

    return ComponentRegistry.isSupported(component, template);
  }

  /// Check if template key is valid
  static bool isValidTemplate(String templateKey) {
    try {
      ProjectTemplate.fromString(templateKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get supported components for current project template
  static Future<List<NameComponent>> getSupportedComponents() async {
    final template = await getTemplateOrNull();
    if (template == null) return [];

    return ComponentRegistry.getComponentsForTemplate(template);
  }

  // ======================== TEMPLATE INFO ========================

  /// Get display name for current project template
  static Future<String?> getTemplateDisplayName() async {
    final template = await getTemplateOrNull();
    if (template == null) return null;

    return getTemplateDisplayNameForTemplate(template);
  }

  /// Get display name for specific template
  static String getTemplateDisplayNameForTemplate(ProjectTemplate template) {
    switch (template) {
      case ProjectTemplate.getx:
        return 'GetX Architecture';
      case ProjectTemplate.clean:
        return 'Clean Architecture';
    }
  }

  /// Get all supported template keys
  static List<String> get supportedTemplates =>
      ProjectTemplate.values.map((t) => t.key).toList();

  // ======================== PACKAGE IMPORTS ========================

  /// Generate package import path for a file
  /// Example: 'lib/app/modules/home/views/home_view.dart' -> 'package:myapp/app/modules/home/views/home_view.dart'
  static Future<String?> generatePackageImport(String filePath) async {
    final projectName = await getName();
    if (projectName == null) return null;

    // Convert absolute path to relative from project root
    final projectRoot = await getRoot();
    if (projectRoot == null) return null;

    // Remove project root and lib/ prefix
    var relativePath = filePath;
    if (relativePath.startsWith(projectRoot)) {
      relativePath = relativePath.substring(projectRoot.length + 1);
    }
    if (relativePath.startsWith('lib/')) {
      relativePath = relativePath.substring(4);
    }

    return 'package:$projectName/$relativePath';
  }

  /// Generate component-specific package import
  ///
  /// Examples:
  /// - getComponentImport(NameComponent.controllers, 'home_controller.dart')
  ///   -> 'package:myapp/app/modules/home/controllers/home_controller.dart'
  /// - getComponentImport(NameComponent.models, 'user_model.dart')
  ///   -> 'package:myapp/app/data/models/user_model.dart'
  /// - getComponentImport(NameComponent.services, 'api_service.dart')
  ///   -> 'package:myapp/app/services/api_service.dart'
  static Future<String?> getComponentImport(
    NameComponent component,
    String fileName,
  ) async {
    final projectName = await getName();
    if (projectName == null) return null;

    final componentPath = await getComponentPathWithoutLib(component);
    if (componentPath.isEmpty) return null;

    // Ensure proper path formatting
    var cleanPath = componentPath;
    if (!cleanPath.endsWith('/')) {
      cleanPath += '/';
    }

    // Ensure proper filename
    var cleanFileName = fileName;
    if (!cleanFileName.endsWith('.dart')) {
      cleanFileName += '.dart';
    }

    return 'package:$projectName/$cleanPath$cleanFileName';
  }

  /// Generate component import with subdirectory support
  ///
  /// Examples:
  /// - getComponentImportWithPath(NameComponent.modules, 'home/controllers', 'home_controller.dart')
  ///   -> 'package:myapp/app/modules/home/controllers/home_controller.dart'
  /// - getComponentImportWithPath(NameComponent.models, 'auth', 'user_model.dart')
  ///   -> 'package:myapp/app/data/models/auth/user_model.dart'
  static Future<String?> getComponentImportWithPath(
    NameComponent component,
    String subPath,
    String fileName,
  ) async {
    final projectName = await getName();
    if (projectName == null) return null;

    final componentPath = await getComponentPathWithoutLib(component);
    if (componentPath.isEmpty) return null;

    // Clean and format paths
    var cleanComponentPath = componentPath;
    if (!cleanComponentPath.endsWith('/')) {
      cleanComponentPath += '/';
    }

    var cleanSubPath = subPath;
    if (cleanSubPath.startsWith('/')) {
      cleanSubPath = cleanSubPath.substring(1);
    }
    if (!cleanSubPath.endsWith('/') && cleanSubPath.isNotEmpty) {
      cleanSubPath += '/';
    }

    var cleanFileName = fileName;
    if (!cleanFileName.endsWith('.dart')) {
      cleanFileName += '.dart';
    }

    return 'package:$projectName/$cleanComponentPath$cleanSubPath$cleanFileName';
  }

  // ======================== UTILITIES ========================

  /// Clear all caches (useful for testing)
  static void clearCache() {
    ConfigService.clearCache();
  }
}

class ProjectData {
  final String name;
  final ProjectTemplate template;

  ProjectData({required this.name, required this.template});
}
