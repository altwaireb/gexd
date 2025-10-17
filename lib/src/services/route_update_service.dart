import 'dart:io';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Service for automatically updating route files when creating screens
class RouteUpdateService implements RouteUpdateServiceInterface {
  final Logger _logger;

  RouteUpdateService({Logger? logger}) : _logger = logger ?? Logger();

  /// Add route for a new screen to app_pages.dart
  @override
  Future<bool> addScreenRoute({
    required String screenName,
    required String? subPath,
    required ProjectTemplate template,
  }) async {
    try {
      final routeFilePath = _getRouteFilePath(template);
      final routesFilePath = _getRoutesFilePath(template);

      if (!File(routeFilePath).existsSync() ||
          !File(routesFilePath).existsSync()) {
        _logger.warn('Route files not found. Please add routes manually.');
        return false;
      }

      // Update app_routes.dart
      await _updateAppRoutes(routesFilePath, screenName, subPath);

      // Update app_pages.dart
      await _updateAppPages(routeFilePath, screenName, subPath, template);

      return true;
    } catch (e) {
      _logger.warn('Failed to update routes automatically: $e');
      return false;
    }
  }

  /// Get route file path based on template
  String _getRouteFilePath(ProjectTemplate template) {
    final routesPath = ArchitectureCoordinator.getComponentPath(
      NameComponent.routes,
      template,
    );
    final appPagesFile = '$routesPath/app_pages.dart';
    return appPagesFile;
  }

  /// Get routes file path based on template
  String _getRoutesFilePath(ProjectTemplate template) {
    final routesPath = ArchitectureCoordinator.getComponentPath(
      NameComponent.routes,
      template,
    );
    final appRoutesFile = '$routesPath/app_routes.dart';
    return appRoutesFile;
  }

  /// Update app_routes.dart with new route constants
  Future<void> _updateAppRoutes(
    String filePath,
    String screenName,
    String? subPath,
  ) async {
    final file = File(filePath);
    final content = await file.readAsString();

    final routeName = StringHelpers.toConstantCase(screenName);
    final routePath = _generateRoutePath(screenName, subPath);

    // Add to Routes class
    final routesRegex = RegExp(
      r'abstract class Routes \{[^}]*\}',
      dotAll: true,
    );
    final routesMatch = routesRegex.firstMatch(content);

    if (routesMatch != null) {
      final routesClass = routesMatch.group(0)!;
      final newRoute = '  static const $routeName = _Paths.$routeName;';

      if (!routesClass.contains(routeName)) {
        final updatedRoutesClass = routesClass.replaceFirst(
          '}',
          '  $newRoute\n}',
        );

        final updatedContent = content.replaceFirst(
          routesClass,
          updatedRoutesClass,
        );

        // Add to _Paths class
        final pathsRegex = RegExp(
          r'abstract class _Paths \{[^}]*\}',
          dotAll: true,
        );
        final pathsMatch = pathsRegex.firstMatch(updatedContent);

        if (pathsMatch != null) {
          final pathsClass = pathsMatch.group(0)!;
          final newPath = '  static const $routeName = \'$routePath\';';

          if (!pathsClass.contains(routeName)) {
            final updatedPathsClass = pathsClass.replaceFirst(
              '}',
              '  $newPath\n}',
            );

            final finalContent = updatedContent.replaceFirst(
              pathsClass,
              updatedPathsClass,
            );
            await file.writeAsString(finalContent);
          }
        }
      }
    }
  }

  /// Update app_pages.dart with new GetPage
  Future<void> _updateAppPages(
    String filePath,
    String screenName,
    String? subPath,
    ProjectTemplate template,
  ) async {
    final file = File(filePath);
    final content = await file.readAsString();

    final routeName = StringHelpers.toConstantCase(screenName);
    final importPath = await _generateImportPath(screenName, subPath, template);

    // Add import statements
    final importRegex = RegExp(r"import '[^']+\.dart';");
    final lastImportMatch = importRegex.allMatches(content).last;

    final screenSnakeCase = screenName.toLowerCase();
    final viewImport =
        "import '$importPath/$screenSnakeCase/views/${screenSnakeCase}_view.dart';";
    final bindingImport =
        "import '$importPath/$screenSnakeCase/bindings/${screenSnakeCase}_binding.dart';";

    String updatedContent = content;

    if (!content.contains(viewImport)) {
      updatedContent = updatedContent.replaceFirst(
        lastImportMatch.group(0)!,
        '${lastImportMatch.group(0)!}\n$viewImport\n$bindingImport',
      );
    }

    // Add GetPage to routes list
    final routesListRegex = RegExp(
      r'static final routes = <GetPage>\[[^\]]*\];',
      dotAll: true,
    );
    final routesMatch = routesListRegex.firstMatch(updatedContent);

    if (routesMatch != null) {
      final routesList = routesMatch.group(0)!;
      final newRoute =
          '''
    GetPage(
      name: _Paths.$routeName,
      page: () => const ${screenName}View(),
      binding: ${screenName}Binding(),
    ),''';

      if (!routesList.contains(routeName)) {
        final updatedRoutesList = routesList.replaceFirst(
          '];',
          '$newRoute\n  ];',
        );

        updatedContent = updatedContent.replaceFirst(
          routesList,
          updatedRoutesList,
        );
        await file.writeAsString(updatedContent);
      }
    }
  }

  /// Generate route path
  String _generateRoutePath(String screenName, String? subPath) {
    final basePath = '/${screenName.toLowerCase()}';
    return subPath != null
        ? '/${subPath.replaceAll('/', '/')}$basePath'
        : basePath;
  }

  /// Generate import path based on template and subPath (using package imports)
  Future<String> _generateImportPath(
    String screenName,
    String? subPath,
    ProjectTemplate template,
  ) async {
    // Get project name from config
    final projectName = await ConfigService.getProjectName();
    if (projectName == null) {
      // Fallback to relative imports if no project name
      return _generateRelativeImportPath(screenName, subPath, template);
    }

    final packageName = StringHelpers.toSnakeCase(projectName);

    // Get base component path without lib/
    final componentPath =
        await ArchitectureCoordinator.getComponentPathByConfigWithoutLib(
          NameComponent.screen,
        );

    // Generate package import path
    if (subPath != null && subPath.isNotEmpty) {
      return 'package:$packageName/$componentPath/$subPath';
    } else {
      return 'package:$packageName/$componentPath';
    }
  }

  /// Fallback to relative imports
  String _generateRelativeImportPath(
    String screenName,
    String? subPath,
    ProjectTemplate template,
  ) {
    switch (template) {
      case ProjectTemplate.getx:
        // From lib/app/core/routes/ to lib/ generated files
        if (subPath != null && subPath.isNotEmpty) {
          return '../../$subPath';
        } else {
          // Files are in lib/ directory
          return '../..';
        }
      case ProjectTemplate.clean:
        // From lib/presentation/routes/ to lib/ generated files
        if (subPath != null && subPath.isNotEmpty) {
          return '../../$subPath';
        } else {
          return '../..';
        }
    }
  }
}
