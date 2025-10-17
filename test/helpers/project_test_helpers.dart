import 'dart:io';
import 'package:path/path.dart' as p;
import 'e2e_helpers.dart';
import 'fake_project_builder.dart';

/// ProjectTestHelpers
///
/// Smart helper that chooses between fake and real project creation
/// based on the environment (local vs CI).
class ProjectTestHelpers {
  /// Determine if we should use fake projects (local testing)
  static bool isLocalTesting() {
    // Check if we're in CI environment
    if (Platform.environment['CI'] == 'true' ||
        Platform.environment['GITHUB_ACTIONS'] == 'true' ||
        Platform.environment['GITHUB_WORKSPACE'] != null) {
      return false; // Use real projects in CI
    }

    // Check if compiled executable exists (indicates local development)
    final projectRoot = _findProjectRoot();
    if (projectRoot.isNotEmpty) {
      final executablePath = p.join(projectRoot, 'bin', 'gexd');
      if (File(executablePath).existsSync()) {
        print('🚀 Using fast fake projects (compiled executable found)');
        return true;
      }
    }

    print('🐌 Using real projects (no compiled executable or CI environment)');
    return false;
  }

  /// Smart project creation - chooses optimal method based on environment
  static Future<TemplateTestProject> smartCreateProject({
    required String templateKey,
    String? projectName,
    Duration? timeout,
    List<String>? platforms,
    bool forInit = false,
  }) async {
    final stopwatch = Stopwatch()..start();

    TemplateTestProject project;

    if (isLocalTesting() && !forInit) {
      // Use fast fake projects locally for make commands
      project = await FakeProjectBuilder.createFakeGexdProject(
        templateKey: templateKey,
        projectName: projectName,
        forInit: forInit,
      );
    } else {
      // Use real projects in CI or for init commands
      project = await E2EHelpers.setupGexdProject(
        templateKey: templateKey,
        projectName: projectName,
        timeout: timeout,
        platforms: platforms,
      );
    }

    stopwatch.stop();
    print('⏱️ Project created in ${stopwatch.elapsedMilliseconds}ms');

    return project;
  }

  /// Smart creation of both GetX and Clean projects
  static Future<TemplateTestProjects> smartCreateBothProjects({
    Duration? timeout,
    List<String>? platforms,
  }) async {
    print('🏗️ Setting up both template projects (smart mode)...');

    final futures = await Future.wait([
      smartCreateProject(
        templateKey: 'getx',
        timeout: timeout,
        platforms: platforms,
      ),
      smartCreateProject(
        templateKey: 'clean',
        timeout: timeout,
        platforms: platforms,
      ),
    ]);

    return TemplateTestProjects(
      getxProject: futures[0],
      cleanProject: futures[1],
    );
  }

  /// Get optimal executable path (compiled vs dart run)
  static Future<ExecutableInfo> getOptimalExecutable() async {
    final projectRoot = _findProjectRoot();

    if (projectRoot.isEmpty) {
      throw StateError('Could not find project root');
    }

    // Check for compiled executable first
    final compiledPath = p.join(projectRoot, 'bin', 'gexd');
    if (File(compiledPath).existsSync() && isLocalTesting()) {
      return ExecutableInfo(
        path: compiledPath,
        isCompiled: true,
        dartPath: null,
      );
    }

    // Fallback to dart run
    final dartExecutable = await findDartExecutable();
    return ExecutableInfo(
      path: p.join(projectRoot, 'bin', 'gexd.dart'),
      isCompiled: false,
      dartPath: dartExecutable,
    );
  }

  /// Measure project creation performance
  static Future<PerformanceMetrics> measureProjectCreation({
    required String templateKey,
    int iterations = 3,
  }) async {
    final stopwatch = Stopwatch();
    final times = <int>[];

    print('📊 Measuring project creation performance...');

    for (int i = 0; i < iterations; i++) {
      stopwatch.reset();
      stopwatch.start();

      final project = await smartCreateProject(
        templateKey: templateKey,
        projectName: 'perf_test_$i',
      );

      stopwatch.stop();
      times.add(stopwatch.elapsedMilliseconds);

      // Cleanup
      await project.cleanup();

      print(
        '🔄 Iteration ${i + 1}/$iterations: ${stopwatch.elapsedMilliseconds}ms',
      );
    }

    final averageTime = times.reduce((a, b) => a + b) / times.length;
    final minTime = times.reduce((a, b) => a < b ? a : b);
    final maxTime = times.reduce((a, b) => a > b ? a : b);

    return PerformanceMetrics(
      averageMs: averageTime.round(),
      minMs: minTime,
      maxMs: maxTime,
      iterations: iterations,
      isFake: isLocalTesting(),
    );
  }

  /// Find the project root directory
  static String _findProjectRoot() {
    try {
      var current = Directory.current;

      // Check current directory first
      if (File(p.join(current.path, 'pubspec.yaml')).existsSync()) {
        final pubspecContent = File(
          p.join(current.path, 'pubspec.yaml'),
        ).readAsStringSync();
        if (pubspecContent.contains('name: gexd')) {
          return current.path;
        }
      }

      // Search up the directory tree
      while (current.parent.path != current.path) {
        final pubspecPath = p.join(current.path, 'pubspec.yaml');
        if (File(pubspecPath).existsSync()) {
          try {
            final pubspecContent = File(pubspecPath).readAsStringSync();
            if (pubspecContent.contains('name: gexd')) {
              return current.path;
            }
          } catch (_) {
            // Continue searching
          }
        }
        current = current.parent;
      }
    } catch (_) {
      // Return empty if error
    }

    return '';
  }

  /// Find Dart executable dynamically
  static Future<String> findDartExecutable() async {
    // Method 1: Check if 'dart' is in PATH
    try {
      final result = await Process.run('which', ['dart']);
      if (result.exitCode == 0) {
        final dartPath = result.stdout.toString().trim();
        if (dartPath.isNotEmpty && File(dartPath).existsSync()) {
          return dartPath;
        }
      }
    } catch (_) {
      // Continue to other methods
    }

    // Method 2: Check Flutter SDK path (common locations)
    final possibleFlutterPaths = [
      Platform.environment['FLUTTER_ROOT'],
      '${Platform.environment['HOME']}/flutter',
      '${Platform.environment['HOME']}/Development/flutter',
      '/usr/local/flutter',
      '/opt/flutter',
    ];

    for (final flutterPath in possibleFlutterPaths) {
      if (flutterPath != null && flutterPath.isNotEmpty) {
        final dartPath = p.join(flutterPath, 'bin', 'dart');
        if (File(dartPath).existsSync()) {
          return dartPath;
        }
      }
    }

    // Method 3: Check DART_SDK environment variable
    final dartSdk = Platform.environment['DART_SDK'];
    if (dartSdk != null && dartSdk.isNotEmpty) {
      final dartPath = p.join(dartSdk, 'bin', 'dart');
      if (File(dartPath).existsSync()) {
        return dartPath;
      }
    }

    // Method 4: Use Platform.resolvedExecutable as fallback
    // This is the Dart executable that's currently running
    final currentDart = Platform.resolvedExecutable;
    if (File(currentDart).existsSync()) {
      return currentDart;
    }

    // Last resort: assume 'dart' is in PATH
    return 'dart';
  }

  /// Create fake project for init command testing
  static Future<TemplateTestProject> createEmptyProjectForInit({
    String? projectName,
  }) async {
    return FakeProjectBuilder.createEmptyFlutterProject(
      projectName: projectName,
    );
  }
}

/// Information about the executable to use
class ExecutableInfo {
  final String path;
  final bool isCompiled;
  final String? dartPath;

  ExecutableInfo({required this.path, required this.isCompiled, this.dartPath});

  @override
  String toString() {
    return isCompiled
        ? 'Compiled executable: $path'
        : 'Dart script: $dartPath run $path';
  }
}

/// Performance measurement results
class PerformanceMetrics {
  final int averageMs;
  final int minMs;
  final int maxMs;
  final int iterations;
  final bool isFake;

  PerformanceMetrics({
    required this.averageMs,
    required this.minMs,
    required this.maxMs,
    required this.iterations,
    required this.isFake,
  });

  @override
  String toString() {
    final type = isFake ? 'Fake' : 'Real';
    return '''
📊 Performance Metrics ($type projects):
   Average: ${averageMs}ms
   Range: ${minMs}ms - ${maxMs}ms
   Iterations: $iterations
   Speedup: ${isFake ? '~10x faster' : 'baseline'}
''';
  }
}
