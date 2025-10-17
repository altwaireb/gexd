import 'dart:io';
import 'package:gexd/gexd.dart';
import 'package:path/path.dart' as p;
import 'e2e_validators.dart';
import 'project_test_helpers.dart';

/// E2EHelpers
///
/// Provides a unified interface for setting up test projects, running CLI
/// commands, and validating the generated structure for `gexd`.
class E2EHelpers {
  /// Dynamic Dart executable discovery - cached for performance
  static String? _cachedDartExecutable;
  static Future<String> _getDartExecutable() async {
    _cachedDartExecutable ??= await ProjectTestHelpers.findDartExecutable();
    return _cachedDartExecutable!;
  }

  /// Setup Flutter path in environment dynamically
  static Future<void> _setupFlutterPath(Map<String, String> env) async {
    // Try to find Flutter installation
    final possibleFlutterPaths = [
      Platform.environment['FLUTTER_ROOT'],
      '${Platform.environment['HOME']}/flutter',
      '${Platform.environment['HOME']}/Development/flutter',
      '/usr/local/flutter',
      '/opt/flutter',
    ];

    for (final flutterPath in possibleFlutterPaths) {
      if (flutterPath != null && flutterPath.isNotEmpty) {
        final flutterBin = p.join(flutterPath, 'bin');
        if (Directory(flutterBin).existsSync()) {
          env['PATH'] = '$flutterBin:${env['PATH']}';
          return;
        }
      }
    }

    // If no Flutter found, try to extract from dart executable path
    final dartPath = await _getDartExecutable();
    if (dartPath.contains('flutter')) {
      final flutterBin = dartPath.substring(0, dartPath.lastIndexOf('/'));
      env['PATH'] = '$flutterBin:${env['PATH']}';
    }
  }

  /// Setup a temporary test project for a specific template (e.g., 'getx', 'clean')
  static Future<TemplateTestProject> setupProject({
    required String templateKey,
    bool withGit = false,
    String? projectName,
    List<String>? platforms,
    Duration? timeout,
  }) async {
    final project = await setupGexdProject(
      templateKey: templateKey,
      projectName: projectName,
      platforms: platforms,
      timeout: timeout,
    );
    if (withGit) {
      await Process.run('git', [
        'init',
      ], workingDirectory: project.projectDir.path);
    }
    return project;
  }

  /// Run a CLI command within a specific working directory.
  /// Automatically handles stdout/stderr and exit codes.
  static Future<ProcessResult> runCommand(
    List<String> args, {
    required String workingDir,
    bool verbose = false,
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final executable = await _setupExecutable();
    final dartExecutable = await _getDartExecutable();

    final process = await Process.run(dartExecutable, [
      'run',
      executable,
      ...args,
    ], workingDirectory: workingDir).timeout(timeout);

    if (verbose) {
      stdout.writeln(process.stdout);
      stderr.writeln(process.stderr);
    }

    // Log results for debugging
    if (process.exitCode != 0) {
      print('❌ Command failed with exit code ${process.exitCode}');
      print('stderr: ${process.stderr}');
      print('stdout: ${process.stdout}');
    } else {
      print('✅ Command succeeded with exit code ${process.exitCode}');
    }

    return process;
  }

  /// Detects the correct executable for `gexd`
  static Future<String> _setupExecutable() async {
    // Determine project root first
    String projectRoot;

    if (Platform.environment['GITHUB_WORKSPACE'] != null) {
      projectRoot = Platform.environment['GITHUB_WORKSPACE']!;
    } else {
      projectRoot = _findProjectRoot();
    }

    if (projectRoot.isEmpty) {
      throw StateError(
        '❌ Could not determine Gexd project root. '
        'Set GITHUB_WORKSPACE in CI or run from project root locally.',
      );
    }

    return p.join(projectRoot, 'bin', 'gexd.dart');
  }

  /// Find the Gexd project root by searching for pubspec.yaml
  static String _findProjectRoot() {
    try {
      var current = Directory.current;

      // First check if we're already in the project root
      if (File(p.join(current.path, 'pubspec.yaml')).existsSync()) {
        final pubspecContent = File(
          p.join(current.path, 'pubspec.yaml'),
        ).readAsStringSync();
        if (pubspecContent.contains('name: gexd')) {
          return current.path;
        }
      }

      // If not found, search up the directory tree
      while (current.parent.path != current.path) {
        final pubspecPath = p.join(current.path, 'pubspec.yaml');
        if (File(pubspecPath).existsSync()) {
          try {
            final pubspecContent = File(pubspecPath).readAsStringSync();
            if (pubspecContent.contains('name: gexd')) {
              return current.path;
            }
          } catch (_) {
            // Continue searching if can't read file
          }
        }
        current = current.parent;
      }
    } catch (_) {
      // Continue to other strategies
    }

    return '';
  }

  /// Validate the generated project structure according to the template
  static Future<void> validateStructure({
    required String templateKey,
    required Directory projectDir,
  }) async {
    if (templateKey == 'getx') {
      await E2EValidators.validateGetXStructure(projectDir);
    } else if (templateKey == 'clean') {
      await E2EValidators.validateCleanStructure(projectDir);
    } else {
      throw ValidationException.invalidOption('templateKey', templateKey, [
        'getx',
        'clean',
      ]);
    }
  }

  /// Check if Flutter is available in the system
  static Future<bool> isFlutterAvailable() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Run pub get in a project directory
  static Future<ProcessResult> runPubGet(String projectPath) async {
    final dartExecutable = await _getDartExecutable();
    final result = await Process.run(dartExecutable, [
      'pub',
      'get',
    ], workingDirectory: projectPath);

    if (result.exitCode != 0) {
      print('❌ pub get failed: ${result.stderr}');
    } else {
      print('✅ pub get succeeded');
    }

    return result;
  }

  /// Creates a temporary, isolated directory for each test run
  static Future<Directory> createTemp([String prefix = 'gexd_test_']) async {
    final dir = await Directory.systemTemp.createTemp(prefix);
    print('🧪 Created temp dir: ${dir.path}');
    return dir;
  }

  /// Deletes the temporary directory created for the test
  static Future<void> cleanupDir(Directory dir) async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      print('🧹 Cleaned up ${dir.path}');
    }
  }

  /// Verifies that a generated Flutter project contains the essential files
  static bool validateBasicStructure(String projectPath) {
    final files = ['pubspec.yaml', 'lib/main.dart', 'test/widget_test.dart'];

    final missing = files.where(
      (f) => !File(p.join(projectPath, f)).existsSync(),
    );

    if (missing.isEmpty) {
      print('✅ Valid project structure');
      return true;
    } else {
      print('❌ Missing files: ${missing.join(', ')}');
      return false;
    }
  }

  /// Verifies GetX-specific structure
  static bool validateGetXStructure(String projectPath) {
    final getxFiles = [
      'lib/app/core/bindings/initial_binding.dart',
      'lib/app/core/themes/app_theme.dart',
      'lib/app/core/routes/app_routes.dart',
      'lib/app/modules/home/controllers/home_controller.dart',
    ];

    final existing = getxFiles.where(
      (f) => File(p.join(projectPath, f)).existsSync(),
    );

    print('✅ Found GetX files: ${existing.length}/${getxFiles.length}');
    return existing.length >= 2; // At least some GetX structure
  }

  /// Verifies Clean Architecture structure
  static bool validateCleanStructure(String projectPath) {
    final cleanFiles = [
      'lib/core/bindings/initial_binding.dart',
      'lib/core/themes/app_theme.dart',
      'lib/presentation/routes/app_routes.dart',
      'lib/presentation/pages/home/controllers/home_controller.dart',
    ];

    final existing = cleanFiles.where(
      (f) => File(p.join(projectPath, f)).existsSync(),
    );

    print(
      '✅ Found Clean Architecture files: ${existing.length}/${cleanFiles.length}',
    );
    return existing.length >= 2; // At least some Clean structure
  }

  /// Run a command and return ProcessResult
  static Future<ProcessResult> runCommandDirect(
    List<String> command, {
    String? workingDirectory,
    Duration? timeout,
  }) async {
    return await Process.run(
      command.first,
      command.skip(1).toList(),
      workingDirectory: workingDirectory,
    ).timeout(timeout ?? const Duration(minutes: 3));
  }

  /// Runs the Gexd CLI using `dart run bin/gexd.dart`
  static Future<ProcessResult> runGexd(
    List<String> args, {
    String? workingDir,
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final executable = await _setupExecutable();
    final dartExecutable = await _getDartExecutable();

    // Set environment to include Flutter path dynamically
    final env = Map<String, String>.from(Platform.environment);
    await _setupFlutterPath(env);

    final process = await Process.run(
      dartExecutable,
      ['run', executable, ...args],
      workingDirectory: workingDir,
      environment: env,
    ).timeout(timeout);

    if (process.exitCode != 0) {
      print('❌ gexd failed with exit code ${process.exitCode}');
      print('stderr: ${process.stderr}');
      print('stdout: ${process.stdout}');
    } else {
      print('✅ gexd succeeded with exit code ${process.exitCode}');
    }

    return process;
  }

  /// Setup a template project for testing (REAL project creation)
  /// This method always creates real projects - use ProjectTestHelpers.smartCreateProject for optimal choice
  static Future<TemplateTestProject> setupGexdProject({
    required String templateKey,
    String? projectName,
    Duration? timeout,
    List<String>? platforms,
  }) async {
    final actualProjectName =
        projectName ??
        '${templateKey}_test_${DateTime.now().millisecondsSinceEpoch}';
    final tempDir = await Directory.systemTemp.createTemp(
      'gexd_${templateKey}_',
    );

    print('🏗️ Creating REAL $templateKey project: $actualProjectName');

    final result = await runGexd(
      [
        'create',
        actualProjectName,
        '--template',
        templateKey,
        '--org',
        'com.test',
        '--description',
        '$templateKey template test project',
        '--platforms',
        ...(platforms ?? ['android']),
      ],
      timeout: timeout ?? const Duration(minutes: 3),
      workingDir: tempDir.path,
    );

    if (result.exitCode != 0) {
      // Cleanup on failure
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      throw Exception(
        'Failed to create $templateKey project: ${result.stderr}',
      );
    }

    final projectDir = Directory('${tempDir.path}/$actualProjectName');
    if (!await projectDir.exists()) {
      throw Exception(
        'Project directory does not exist after creation: ${projectDir.path}',
      );
    }

    print(
      '✅ REAL $templateKey project created successfully: ${projectDir.path}',
    );
    return TemplateTestProject(
      templateKey: templateKey,
      projectName: actualProjectName,
      projectDir: projectDir,
      tempDir: tempDir,
    );
  }

  /// Setup both GetX and Clean template projects for comparison testing (REAL projects)
  static Future<TemplateTestProjects> setupBothGexdProjects({
    Duration? timeout,
    List<String>? platforms,
  }) async {
    print(
      '🏗️ Setting up both REAL template projects for comparison testing...',
    );

    final getxProject = await setupGexdProject(
      templateKey: 'getx',
      timeout: timeout,
      platforms: platforms,
    );

    final cleanProject = await setupGexdProject(
      templateKey: 'clean',
      timeout: timeout,
      platforms: platforms,
    );

    return TemplateTestProjects(
      getxProject: getxProject,
      cleanProject: cleanProject,
    );
  }

  /// Smart project creation - automatically chooses between fake and real based on environment
  static Future<TemplateTestProject> createProject({
    required String templateKey,
    String? projectName,
    Duration? timeout,
    List<String>? platforms,
    bool forInit = false,
  }) async {
    return ProjectTestHelpers.smartCreateProject(
      templateKey: templateKey,
      projectName: projectName,
      timeout: timeout,
      platforms: platforms,
      forInit: forInit,
    );
  }

  /// Smart creation of both projects - automatically chooses optimal method
  static Future<TemplateTestProjects> createBothProjects({
    Duration? timeout,
    List<String>? platforms,
  }) async {
    return ProjectTestHelpers.smartCreateBothProjects(
      timeout: timeout,
      platforms: platforms,
    );
  }

  /// Check if we're running in local testing mode
  static bool isLocalTesting() {
    return ProjectTestHelpers.isLocalTesting();
  }
}

/// Template test project information
class TemplateTestProject {
  final String templateKey;
  final String projectName;
  final Directory projectDir;
  final Directory tempDir;

  TemplateTestProject({
    required this.templateKey,
    required this.projectName,
    required this.projectDir,
    required this.tempDir,
  });

  /// Cleanup project and temp directory
  Future<void> cleanup() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        print('🧹 Cleaned up $templateKey project: $projectName');
      }
    } catch (e) {
      print('⚠️ Warning: Failed to cleanup $templateKey project: $e');
    }
  }

  /// Check if file exists in project
  Future<bool> fileExists(String relativePath) async {
    final file = File(p.join(projectDir.path, relativePath));
    return await file.exists();
  }

  /// Read file content from project
  Future<String> readFile(String relativePath) async {
    final file = File(p.join(projectDir.path, relativePath));
    return await file.readAsString();
  }

  /// Write file content to project
  Future<void> writeFile(String relativePath, String content) async {
    final file = File(p.join(projectDir.path, relativePath));
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }
}

/// Container for both template projects
class TemplateTestProjects {
  final TemplateTestProject getxProject;
  final TemplateTestProject cleanProject;

  TemplateTestProjects({required this.getxProject, required this.cleanProject});

  /// Cleanup both projects
  Future<void> cleanup() async {
    await Future.wait([getxProject.cleanup(), cleanProject.cleanup()]);
  }
}
