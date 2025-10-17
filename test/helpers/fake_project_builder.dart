import 'dart:io';
import 'package:path/path.dart' as p;
import 'e2e_helpers.dart';

/// FakeProjectBuilder
///
/// Creates lightweight fake Flutter projects for fast local E2E testing.
/// Used when running tests locally to significantly improve test speed.
class FakeProjectBuilder {
  /// Create a fake Gexd project for testing make commands
  static Future<TemplateTestProject> createFakeGexdProject({
    required String templateKey,
    String? projectName,
    bool forInit = false,
  }) async {
    final actualProjectName =
        projectName ??
        '${templateKey}_fake_${DateTime.now().millisecondsSinceEpoch}';

    final tempDir = await Directory.systemTemp.createTemp(
      'gexd_fake_${templateKey}_',
    );
    final projectDir = Directory(p.join(tempDir.path, actualProjectName));
    await projectDir.create(recursive: true);

    print('🚀 Creating fake $templateKey project: $actualProjectName');

    if (forInit) {
      // For init command - create empty Flutter project only
      await _createBasicFlutterStructure(projectDir.path, actualProjectName);
    } else {
      // For make commands - create full fake structure
      await _createBasicFlutterStructure(projectDir.path, actualProjectName);
      await _createGexdConfig(projectDir.path, actualProjectName, templateKey);
      await _createTemplateRoutes(projectDir.path, templateKey);
    }

    print('✅ Fake $templateKey project created in: ${projectDir.path}');

    return TemplateTestProject(
      templateKey: templateKey,
      projectName: actualProjectName,
      projectDir: projectDir,
      tempDir: tempDir,
    );
  }

  /// Create basic Flutter project structure
  static Future<void> _createBasicFlutterStructure(
    String projectPath,
    String projectName,
  ) async {
    // Create lib directory and main.dart
    final libDir = Directory(p.join(projectPath, 'lib'));
    await libDir.create(recursive: true);

    final mainFile = File(p.join(libDir.path, 'main.dart'));
    await mainFile.writeAsString('''
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$projectName',
      home: Scaffold(
        appBar: AppBar(title: Text('$projectName')),
        body: Center(child: Text('Hello World')),
      ),
    );
  }
}
''');

    // Create test directory and widget_test.dart
    final testDir = Directory(p.join(projectPath, 'test'));
    await testDir.create(recursive: true);

    final testFile = File(p.join(testDir.path, 'widget_test.dart'));
    await testFile.writeAsString('''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:$projectName/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('Hello World'), findsOneWidget);
  });
}
''');

    // Create pubspec.yaml
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    await pubspecFile.writeAsString('''
name: $projectName
description: A fake Flutter project for testing.
version: 1.0.0+1

environment:
  sdk: '>=3.8.1 <4.0.0'
  flutter: ">=3.32.1"

dependencies:
  flutter:
    sdk: flutter
  get: ^4.7.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
''');
  }

  /// Create .gexd/config.yaml
  static Future<void> _createGexdConfig(
    String projectPath,
    String projectName,
    String templateKey,
  ) async {
    final gexdDir = Directory(p.join(projectPath, '.gexd'));
    await gexdDir.create(recursive: true);

    final configFile = File(p.join(gexdDir.path, 'config.yaml'));
    await configFile.writeAsString('''
# Generation Details
generated_by: Gexd CLI
creation_version: 1.0.0
current_version: 1.0.0
generated_date: ${DateTime.now().toIso8601String()}
last_updated: null

# Project Information
project_name: $projectName
template: $templateKey
org: com.test
description: Fake $templateKey project for testing
platforms:
  - android

# Template Configuration
template_config:
  use_get_x: ${templateKey == 'getx'}
  use_clean_architecture: ${templateKey == 'clean'}
''');
  }

  /// Create template-specific route files
  static Future<void> _createTemplateRoutes(
    String projectPath,
    String templateKey,
  ) async {
    if (templateKey == 'getx') {
      await _createGetxRoutes(projectPath);
    } else if (templateKey == 'clean') {
      await _createCleanRoutes(projectPath);
    }
  }

  /// Create GetX route structure
  static Future<void> _createGetxRoutes(String projectPath) async {
    // Create app/routes directory
    final routesDir = Directory(p.join(projectPath, 'lib', 'app', 'routes'));
    await routesDir.create(recursive: true);

    // Create app_routes.dart
    final routesFile = File(p.join(routesDir.path, 'app_routes.dart'));
    await routesFile.writeAsString('''
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
}
''');

    // Create app_pages.dart
    final pagesFile = File(p.join(routesDir.path, 'app_pages.dart'));
    await pagesFile.writeAsString('''
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => Container(), // Placeholder
    ),
  ];
}
''');

    // Create modules directory structure
    final modulesDir = Directory(p.join(projectPath, 'lib', 'app', 'modules'));
    await modulesDir.create(recursive: true);

    // Create core directories
    final coreBindingsDir = Directory(
      p.join(projectPath, 'lib', 'app', 'core', 'bindings'),
    );
    await coreBindingsDir.create(recursive: true);

    final initialBindingFile = File(
      p.join(coreBindingsDir.path, 'initial_binding.dart'),
    );
    await initialBindingFile.writeAsString('''
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initial bindings
  }
}
''');
  }

  /// Create Clean Architecture route structure
  static Future<void> _createCleanRoutes(String projectPath) async {
    // Create presentation/routes directory
    final routesDir = Directory(
      p.join(projectPath, 'lib', 'presentation', 'routes'),
    );
    await routesDir.create(recursive: true);

    // Create app_routes.dart
    final routesFile = File(p.join(routesDir.path, 'app_routes.dart'));
    await routesFile.writeAsString('''
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
}
''');

    // Create app_pages.dart
    final pagesFile = File(p.join(routesDir.path, 'app_pages.dart'));
    await pagesFile.writeAsString('''
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => Container(), // Placeholder
    ),
  ];
}
''');

    // Create pages directory structure
    final pagesDir = Directory(
      p.join(projectPath, 'lib', 'presentation', 'pages'),
    );
    await pagesDir.create(recursive: true);

    // Create core directories
    final coreBindingsDir = Directory(
      p.join(projectPath, 'lib', 'core', 'bindings'),
    );
    await coreBindingsDir.create(recursive: true);

    final initialBindingFile = File(
      p.join(coreBindingsDir.path, 'initial_binding.dart'),
    );
    await initialBindingFile.writeAsString('''
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initial bindings
  }
}
''');
  }

  /// Create empty Flutter project for init command testing
  static Future<TemplateTestProject> createEmptyFlutterProject({
    String? projectName,
  }) async {
    return createFakeGexdProject(
      templateKey: 'empty',
      projectName: projectName,
      forInit: true,
    );
  }
}
