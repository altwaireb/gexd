import 'package:gexd/src/core/enums/project_template.dart';
import 'package:path/path.dart' as path;

import '../core/enums/name_component.dart';
import 'component_registry.dart';
import '../services/config_service.dart';

/// ArchitectureCoordinator
/// Abstraction that provides unified access to paths, supported components, and validations.
class ArchitectureCoordinator {
  ArchitectureCoordinator._();

  /// Return folder paths for supported components for a specific template.
  /// If full == false, returns only essential components.
  static List<String> getDirectories(
    ProjectTemplate template, {
    bool full = false,
  }) {
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

  /// Return default path for a specific component in a specific template (or '' if not found).
  static String getComponentPath(
    NameComponent component,
    ProjectTemplate template,
  ) {
    return ComponentRegistry.getPath(component, template) ?? '';
  }

  /// Return component path with appended 'on' path if provided
  /// Returns just the component path if onPath is null or empty
  static String getComponentWithOnPath({
    required NameComponent component,
    required ProjectTemplate template,
    required String? onPath,
  }) {
    if (onPath != null && onPath.isNotEmpty) {
      final basePath = ComponentRegistry.getPath(component, template);
      if (basePath != null && basePath.isNotEmpty) {
        return '$basePath/$onPath';
      }
    }
    return ComponentRegistry.getPath(component, template) ?? '';
  }

  /// Return component path with onPath but without 'lib/' prefix (for imports)
  /// This is specifically useful for generating import statements
  static String getComponentWithOnPathWithoutLib({
    required NameComponent component,
    required ProjectTemplate template,
    required String? onPath,
  }) {
    final fullPath = getComponentWithOnPath(
      component: component,
      template: template,
      onPath: onPath,
    );

    return removeLibPrefix(fullPath);
  }

  /// Get full absolute target path for component generation
  /// Combines project directory, component base path, and optional onPath
  /// This is the unified method for all make commands to determine target directory
  static String getFullTargetPath({
    required String projectPath,
    required NameComponent component,
    required ProjectTemplate template,
    required String? onPath,
  }) {
    final componentWithOnPath = getComponentWithOnPath(
      component: component,
      template: template,
      onPath: onPath,
    );

    // Use path.join for proper cross-platform path handling
    return path.join(projectPath, componentWithOnPath);
  }

  /// Async version that auto-detects template from project config
  /// Used for screen generation and other cases where template is not readily available
  static Future<String> getFullTargetPathByConfig({
    required String projectPath,
    required NameComponent component,
    required String? onPath,
  }) async {
    final template = await getCurrentProjectTemplate();
    if (template == null) {
      throw Exception('Not inside a valid Gexd project');
    }

    return getFullTargetPath(
      projectPath: projectPath,
      component: component,
      template: template,
      onPath: onPath,
    );
  }

  /// Get component path with appended suffix
  /// Returns the component path with the specified suffix appended.
  static String getComponentWithSuffixPath({
    required NameComponent component,
    required ProjectTemplate template,
    required String? onPath,
    required String suffix,
  }) {
    final fullPath = getComponentWithOnPath(
      component: component,
      template: template,
      onPath: onPath,
    );

    return '$fullPath/$suffix';
  }

  /// Get import path for component with appended suffix
  /// Returns the package import path for the component with the specified suffix.
  static String getImportComponentWithSuffixPath({
    required NameComponent component,
    required ProjectTemplate template,
    required String? onPath,
    required String projectName,
    required String suffix,
  }) {
    final fullPath = getComponentWithOnPathWithoutLib(
      component: component,
      template: template,
      onPath: onPath,
    );

    return 'package:$projectName/$fullPath/$suffix';
  }

  /// Smart function that reads template from .gexd/config.yaml and returns component path
  /// Returns the path for the component based on the current project's template configuration
  /// Returns empty string if:
  /// - Not in a Gexd project
  /// - Component is not supported for the detected template
  /// - Failed to read project configuration
  static Future<String> getComponentPathByConfig(
    NameComponent component,
  ) async {
    try {
      // Read template from project configuration
      final template = await ConfigService.getProjectTemplate();

      // If not in Gexd project or template not found
      if (template == null) {
        return '';
      }

      // Return component path for the detected template
      return getComponentPath(component, template);
    } catch (e) {
      // Return empty string on any error
      return '';
    }
  }

  /// Get component path without 'lib/' prefix for package imports
  static Future<String> getComponentPathByConfigWithoutLib(
    NameComponent component,
  ) async {
    final fullPath = await getComponentPathByConfig(component);
    return removeLibPrefix(fullPath);
  }

  /// Get component path without 'lib/' prefix for a specific template
  static String getComponentPathWithoutLib(
    NameComponent component,
    ProjectTemplate template,
  ) {
    final fullPath = getComponentPath(component, template);
    return removeLibPrefix(fullPath);
  }

  /// Helper method to remove 'lib/' prefix from path
  /// This is the centralized utility for path prefix removal
  static String removeLibPrefix(String path) {
    return path.startsWith('lib/') ? path.substring(4) : path;
  }

  /// Get current project template from config
  /// Returns null if not in Gexd project or failed to read config
  static Future<ProjectTemplate?> getCurrentProjectTemplate() async {
    return await ConfigService.getProjectTemplate();
  }

  /// Check if component is supported in current project
  /// Returns false if not in Gexd project or component not supported
  static Future<bool> isComponentSupportedInCurrentProject(
    NameComponent component,
  ) async {
    try {
      final template = await ConfigService.getProjectTemplate();
      if (template == null) return false;

      return isComponentSupported(component, template);
    } catch (e) {
      return false;
    }
  }

  /// Check if component is supported for that template.
  static bool isComponentSupported(
    NameComponent component,
    ProjectTemplate template,
  ) {
    return ComponentRegistry.isSupported(component, template);
  }

  /// List of supported NameComponent for template
  static List<NameComponent> getSupportedComponents(ProjectTemplate template) {
    return ComponentRegistry.getComponentsForTemplate(template);
  }

  /// Check if template key is valid (makes it easy to use from CLI)
  static bool isValidTemplate(String templateKey) {
    try {
      ProjectTemplate.fromString(templateKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// All supported template keys as text list (useful for CLI).
  static List<String> get supportedTemplates =>
      ProjectTemplate.values.map((t) => t.key).toList();

  /// Template name for display
  static String getTemplateDisplayName(ProjectTemplate template) {
    switch (template) {
      case ProjectTemplate.getx:
        return 'GetX Architecture';
      case ProjectTemplate.clean:
        return 'Clean Architecture';
    }
  }
}
