import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'e2e_helpers.dart';

/// OptimizedTestManager
///
/// Advanced test speed optimization using sophisticated strategies:
/// 1. Template Caching - Cache templates temporarily
/// 2. Fast Fake Projects - Quick fake project generation
/// 3. Smart Structure Generation - Intelligent structure creation
///
/// Goal: Reduce test time from 30+ minutes to 3-5 minutes
class OptimizedTestManager {
  static final Map<String, _CachedTemplate> _templateCache = {};
  static bool _isInitialized = false;

  /// Initial setup for the optimized manager
  static Future<void> initialize() async {
    if (_isInitialized) return;

    print('🚀 Initializing OptimizedTestManager...');

    // Prepare cache for common templates
    await _preloadTemplates(['getx', 'clean']);

    _isInitialized = true;
    print('✅ OptimizedTestManager ready!');
  }

  /// Create optimized project using advanced strategies
  static Future<TemplateTestProject> createOptimizedProject({
    required String templateKey,
    String? projectName,
    bool verbose = false,
    bool withJsonModel = false,
    String modelJsonName = 'test_model',
  }) async {
    await initialize();

    final stopwatch = Stopwatch()..start();

    if (verbose) {
      print('🏗️ Creating optimized $templateKey project...');
    }

    try {
      // 1. Create fast basic fake project
      final project = await _createBaseFakeProject(
        templateKey: templateKey,
        projectName: projectName,
      );

      // 2. Add optimized structure using cached templates
      await _addOptimizedStructure(project, templateKey);

      // 3. Create necessary configuration files
      await _createEssentialConfig(project, templateKey);

      // 4. Create JSON model file if requested
      if (withJsonModel) {
        await _createJsonModelFile(project, modelJsonName, verbose: verbose);
      }

      stopwatch.stop();

      if (verbose) {
        print(
          '⚡ Optimized project created in ${stopwatch.elapsedMilliseconds}ms',
        );
      }

      return project;
    } catch (error) {
      stopwatch.stop();
      print('❌ Failed to create optimized project: $error');
      rethrow;
    }
  }

  /// Create both optimized projects (GetX + Clean) for comparison
  static Future<TemplateTestProjects> createOptimizedBothProjects({
    bool verbose = false,
  }) async {
    print('🏗️ Creating both optimized projects...');

    final futures = await Future.wait([
      createOptimizedProject(templateKey: 'getx', verbose: verbose),
      createOptimizedProject(templateKey: 'clean', verbose: verbose),
    ]);

    return TemplateTestProjects(
      getxProject: futures[0],
      cleanProject: futures[1],
    );
  }

  /// Performance comparison between traditional and optimized methods
  static Future<PerformanceComparison> benchmarkPerformance({
    String templateKey = 'getx',
    bool verbose = true,
  }) async {
    print('📊 Starting performance benchmark...');

    // Measure traditional method
    final traditionalStopwatch = Stopwatch()..start();
    final traditionalProject = await E2EHelpers.setupGexdProject(
      templateKey: templateKey,
    );
    traditionalStopwatch.stop();
    await traditionalProject.cleanup();

    // Measure optimized method
    final optimizedStopwatch = Stopwatch()..start();
    final optimizedProject = await createOptimizedProject(
      templateKey: templateKey,
      verbose: verbose,
    );
    optimizedStopwatch.stop();
    await optimizedProject.cleanup();

    final comparison = PerformanceComparison(
      traditionalTime: traditionalStopwatch.elapsedMilliseconds,
      optimizedTime: optimizedStopwatch.elapsedMilliseconds,
      templateKey: templateKey,
    );

    if (verbose) {
      print('📊 Performance Results:');
      print('   Traditional: ${comparison.traditionalTime}ms');
      print('   Optimized: ${comparison.optimizedTime}ms');
      print('   Speedup: ${comparison.speedupFactor}x faster');
      print('   Time saved: ${comparison.timeSaved}ms');
    }

    return comparison;
  }

  /// Clear cache and reset state
  static void clearCache() {
    _templateCache.clear();
    _isInitialized = false;
    print('🧹 Template cache cleared');
  }

  /// Create JSON model file for testing
  static Future<void> _createJsonModelFile(
    TemplateTestProject project,
    String modelJsonName, {
    bool verbose = false,
  }) async {
    if (verbose) {
      print('📄 Creating JSON model file: $modelJsonName.json');
    }

    final assetsDir = Directory(
      p.join(project.projectDir.path, 'assets', 'models'),
    );
    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }

    final jsonFile = File(p.join(assetsDir.path, '$modelJsonName.json'));

    // Create simple test JSON content
    final jsonContent = _generateTestJsonContent(modelJsonName);

    await jsonFile.writeAsString(jsonContent);

    if (verbose) {
      print('✅ JSON model file created: ${jsonFile.path}');
    }
  }

  /// Generate test JSON content for model
  static String _generateTestJsonContent(String modelName) {
    // Simple test data with common fields for testing
    final Map<String, dynamic> testData = {
      'id': 1,
      'name':
          'Test ${modelName.replaceAll('_', ' ').split(' ').map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)).join(' ')}',
      'description': 'A test model for $modelName',
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'metadata': {
        'version': '1.0.0',
        'source': 'test',
        'tags': ['test', 'model', 'automated'],
      },
      'items': [
        {'itemId': 'item_1', 'value': 'First item', 'priority': 1},
        {'itemId': 'item_2', 'value': 'Second item', 'priority': 2},
      ],
      'settings': {'theme': 'light', 'notifications': true, 'autoSave': false},
    };

    // Convert to formatted JSON
    return const JsonEncoder.withIndent('  ').convert(testData);
  }

  // === Private Methods ===

  /// Preload common templates
  static Future<void> _preloadTemplates(List<String> templates) async {
    for (final template in templates) {
      if (!_templateCache.containsKey(template)) {
        print('📦 Preloading $template template...');
        _templateCache[template] = await _createCachedTemplate(template);
      }
    }
  }

  /// Create cached template
  static Future<_CachedTemplate> _createCachedTemplate(
    String templateKey,
  ) async {
    // In the future: can cache real Mason templates here
    // Now: save required structure information

    return _CachedTemplate(
      templateKey: templateKey,
      structure: _getTemplateStructure(templateKey),
      createdAt: DateTime.now(),
    );
  }

  /// Create basic fake project
  static Future<TemplateTestProject> _createBaseFakeProject({
    required String templateKey,
    String? projectName,
  }) async {
    final actualProjectName =
        projectName ??
        '${templateKey}_opt_${DateTime.now().millisecondsSinceEpoch}';

    final tempDir = await Directory.systemTemp.createTemp(
      'gexd_opt_${templateKey}_',
    );
    final projectDir = Directory(p.join(tempDir.path, actualProjectName));
    await projectDir.create(recursive: true);

    return TemplateTestProject(
      templateKey: templateKey,
      projectName: actualProjectName,
      projectDir: projectDir,
      tempDir: tempDir,
    );
  }

  /// Add optimized structure to project
  static Future<void> _addOptimizedStructure(
    TemplateTestProject project,
    String templateKey,
  ) async {
    final structure = _getTemplateStructure(templateKey);

    for (final dir in structure.directories) {
      await Directory(
        p.join(project.projectDir.path, dir),
      ).create(recursive: true);
    }

    for (final fileInfo in structure.files) {
      final filePath = p.join(project.projectDir.path, fileInfo.path);
      await File(filePath).writeAsString(fileInfo.content);
    }
  }

  /// Create essential configuration files
  static Future<void> _createEssentialConfig(
    TemplateTestProject project,
    String templateKey,
  ) async {
    // Create .gexd/config.yaml with same format as ConfigService.createConfig()
    final gexdDir = Directory(p.join(project.projectDir.path, '.gexd'));
    await gexdDir.create(recursive: true);

    final configFile = File(p.join(gexdDir.path, 'config.yaml'));
    final now = DateTime.now().toIso8601String();
    await configFile.writeAsString('''generated_by: Gexd CLI
creation_version: 1.0.0
current_version: 1.0.0
generated_date: $now
last_updated: null
project_name: ${project.projectName}
template: $templateKey
''');

    // Create basic pubspec.yaml
    final pubspecFile = File(p.join(project.projectDir.path, 'pubspec.yaml'));
    await pubspecFile.writeAsString(
      _getPubspecContent(project.projectName, templateKey),
    );
  }

  /// Get structure for specific template
  static _TemplateStructure _getTemplateStructure(String templateKey) {
    switch (templateKey) {
      case 'getx':
        return _TemplateStructure(
          directories: [
            'lib/app/core/bindings',
            'lib/app/core/themes',
            'lib/app/core/routes',
            'lib/app/modules/home/controllers',
            'lib/app/modules/home/views',
            'lib/app/modules/home/bindings',
            'lib/app/data/models',
            'test',
          ],
          files: [
            _FileInfo('lib/main.dart', _getMainDartContent('getx')),
            _FileInfo(
              'lib/app/core/routes/app_routes.dart',
              _getAppRoutesContent('getx'),
            ),
            _FileInfo(
              'lib/app/core/routes/app_pages.dart',
              _getAppPagesContent('getx'),
            ),
            _FileInfo(
              'lib/app/modules/home/controllers/home_controller.dart',
              _getHomeControllerContent('getx'),
            ),
            _FileInfo(
              'lib/app/modules/home/views/home_view.dart',
              _getHomeViewContent('getx'),
            ),
            _FileInfo(
              'lib/app/modules/home/bindings/home_binding.dart',
              _getHomeBindingContent('getx'),
            ),
            _FileInfo('test/widget_test.dart', _getWidgetTestContent()),
          ],
        );

      case 'clean':
        return _TemplateStructure(
          directories: [
            'lib/core/bindings',
            'lib/core/themes',
            'lib/presentation/routes',
            'lib/presentation/pages/home/controllers',
            'lib/presentation/pages/home/views',
            'lib/presentation/pages/home/bindings',
            'lib/data/models',
            'test',
          ],
          files: [
            _FileInfo('lib/main.dart', _getMainDartContent('clean')),
            _FileInfo(
              'lib/presentation/routes/app_routes.dart',
              _getAppRoutesContent('clean'),
            ),
            _FileInfo(
              'lib/presentation/routes/app_pages.dart',
              _getAppPagesContent('clean'),
            ),
            _FileInfo(
              'lib/presentation/pages/home/controllers/home_controller.dart',
              _getHomeControllerContent('clean'),
            ),
            _FileInfo(
              'lib/presentation/pages/home/views/home_view.dart',
              _getHomeViewContent('clean'),
            ),
            _FileInfo(
              'lib/presentation/pages/home/bindings/home_binding.dart',
              _getHomeBindingContent('clean'),
            ),
            _FileInfo('test/widget_test.dart', _getWidgetTestContent()),
          ],
        );

      default:
        throw ArgumentError('Unsupported template: $templateKey');
    }
  }

  /// pubspec.yaml content
  static String _getPubspecContent(String projectName, String templateKey) {
    return '''
name: $projectName
description: A Flutter project generated with gexd ($templateKey template).
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  get: ^4.6.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
''';
  }

  /// main.dart content
  static String _getMainDartContent(String templateKey) {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gexd App ($templateKey)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Welcome to Gexd ($templateKey template)!'),
      ),
    );
  }
}
''';
  }

  /// app_routes.dart content
  static String _getAppRoutesContent(String templateKey) {
    return '''
abstract class AppRoutes {
  static const HOME = '/home';
}
''';
  }

  /// app_pages.dart content
  static String _getAppPagesContent(String templateKey) {
    return '''
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.HOME;
  
  static final routes = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => Container(), // Placeholder
    ),
  ];
}
''';
  }

  /// widget_test.dart content
  static String _getWidgetTestContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // This is a placeholder test
    expect(true, isTrue);
  });
}
''';
  }

  /// home_controller.dart content
  static String _getHomeControllerContent(String templateKey) {
    return '''
import 'package:get/get.dart';

class HomeController extends GetxController {
  final count = 0.obs;
  
  void increment() => count.value++;
  
  @override
  void onInit() {
    super.onInit();
  }
  
  @override
  void onReady() {
    super.onReady();
  }
  
  @override
  void onClose() {
    super.onClose();
  }
}
''';
  }

  /// home_view.dart content
  static String _getHomeViewContent(String templateKey) {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome to Gexd ($templateKey)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
''';
  }

  /// home_binding.dart content
  static String _getHomeBindingContent(String templateKey) {
    return '''
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
''';
  }
}

// === Supporting Classes ===

class _CachedTemplate {
  final String templateKey;
  final _TemplateStructure structure;
  final DateTime createdAt;

  _CachedTemplate({
    required this.templateKey,
    required this.structure,
    required this.createdAt,
  });
}

class _TemplateStructure {
  final List<String> directories;
  final List<_FileInfo> files;

  _TemplateStructure({required this.directories, required this.files});
}

class _FileInfo {
  final String path;
  final String content;

  _FileInfo(this.path, this.content);
}

class PerformanceComparison {
  final int traditionalTime;
  final int optimizedTime;
  final String templateKey;

  PerformanceComparison({
    required this.traditionalTime,
    required this.optimizedTime,
    required this.templateKey,
  });

  double get speedupFactor => traditionalTime / optimizedTime;
  int get timeSaved => traditionalTime - optimizedTime;
  double get improvementPercentage => (timeSaved / traditionalTime) * 100;
}
