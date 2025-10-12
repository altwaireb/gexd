import 'dart:io';
import 'package:path/path.dart' as p;

/// E2EHelper - A lightweight utility for end-to-end testing of the Gexd CLI.
class E2EHelper {
  static final _root = Directory.current.path;

  /// Creates a temporary, isolated directory for each test run.
  static Future<Directory> createTemp([String prefix = 'gexd_test_']) async {
    final dir = await Directory.systemTemp.createTemp(prefix);
    print('🧪 Created temp dir: ${dir.path}');
    return dir;
  }

  /// Runs the Gexd CLI using `dart run bin/gexd.dart`.
  static Future<ProcessResult> runGexd(
    List<String> args, {
    String? workingDir,
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final binPath = p.join(_root, 'bin', 'gexd.dart');

    final process = await Process.run('dart', [
      'run',
      binPath,
      ...args,
    ], workingDirectory: workingDir ?? _root).timeout(timeout);

    if (process.exitCode != 0) {
      print('❌ gexd failed with exit code ${process.exitCode}');
      print('stderr: ${process.stderr}');
      print('stdout: ${process.stdout}');
    } else {
      print('✅ gexd succeeded with exit code ${process.exitCode}');
    }

    return process;
  }

  /// Deletes the temporary directory created for the test.
  static Future<void> cleanup(Directory dir) async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      print('🧹 Cleaned up ${dir.path}');
    }
  }

  /// Verifies that a generated Flutter project contains the essential files.
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

  /// Runs `dart pub get` inside a given project directory.
  static Future<ProcessResult> runPubGet(String projectPath) async {
    final result = await Process.run('dart', [
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
}
