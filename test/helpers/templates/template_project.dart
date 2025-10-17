import 'dart:io';
import 'package:gexd/gexd.dart';
import 'package:path/path.dart' as p;

/// TemplateTestProject
///
/// Represents a single temporary project used for testing.
/// Handles setup, cleanup, and provides access to the project directory.
class TemplateTestProject {
  final Directory projectDir;
  final Directory tempDir;
  final String templateKey;
  final String projectName;

  TemplateTestProject._({
    required this.projectDir,
    required this.tempDir,
    required this.templateKey,
    required this.projectName,
  });

  /// Create a temporary project by running the CLI `create` command
  static Future<TemplateTestProject> create(
    String templateKey, {
    String? projectName,
    List<String>? platforms,
    Duration? timeout,
  }) async {
    final actualProjectName =
        projectName ??
        '${templateKey}_test_${DateTime.now().millisecondsSinceEpoch}';

    final tempDir = await Directory.systemTemp.createTemp(
      'gexd_${templateKey}_',
    );

    print('🏗️ Creating $templateKey project: $actualProjectName');

    // Find the gexd executable
    final executable = await _findGexdExecutable();

    final result = await Process.run(
      'dart',
      [
        'run',
        executable,
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
      workingDirectory: tempDir.path,
    ).timeout(timeout ?? const Duration(minutes: 3));

    if (result.exitCode != 0) {
      // Cleanup on failure
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      throw ValidationException.custom(
        'Failed to create $templateKey project: ${result.stderr}',
      );
    }

    final projectDir = Directory('${tempDir.path}/$actualProjectName');
    if (!await projectDir.exists()) {
      throw ValidationException.custom(
        'Project directory does not exist after creation: ${projectDir.path}',
      );
    }

    print('✅ $templateKey project created successfully: ${projectDir.path}');

    return TemplateTestProject._(
      projectDir: projectDir,
      tempDir: tempDir,
      templateKey: templateKey,
      projectName: actualProjectName,
    );
  }

  /// Find the gexd executable by searching up the directory tree
  static Future<String> _findGexdExecutable() async {
    var current = Directory.current;

    // First, check current directory
    final currentPubspec = File(p.join(current.path, 'pubspec.yaml'));
    if (await currentPubspec.exists()) {
      final content = await currentPubspec.readAsString();
      if (content.contains('name: gexd')) {
        final executable = p.join(current.path, 'bin', 'gexd.dart');
        print('📍 Found gexd executable: $executable');
        return executable;
      }
    }

    // Search up the directory tree
    while (current.path != current.parent.path) {
      final pubspec = File(p.join(current.path, 'pubspec.yaml'));
      if (await pubspec.exists()) {
        final content = await pubspec.readAsString();
        if (content.contains('name: gexd')) {
          final executable = p.join(current.path, 'bin', 'gexd.dart');
          print('📍 Found gexd executable: $executable');
          return executable;
        }
      }
      current = current.parent;
    }

    // If we're in a test subdirectory, try going up more levels
    final potentialPaths = [
      p.join(Directory.current.path, 'bin', 'gexd.dart'),
      p.join(Directory.current.path, '..', 'bin', 'gexd.dart'),
      p.join(Directory.current.path, '..', '..', 'bin', 'gexd.dart'),
      p.join(Directory.current.path, '..', '..', '..', 'bin', 'gexd.dart'),
    ];

    for (final path in potentialPaths) {
      final file = File(path);
      if (await file.exists()) {
        print('📍 Found gexd executable at: $path');
        return path;
      }
    }

    print('⚠️ Could not find gexd executable, using fallback');
    return 'bin/gexd.dart';
  }

  /// Delete the project directory and its contents
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

  /// Get the path to the project directory
  String get path => projectDir.path;

  /// Check if a file exists in the project
  Future<bool> fileExists(String relativePath) async {
    final file = File(p.join(projectDir.path, relativePath));
    return await file.exists();
  }

  /// Read a file from the project directory
  Future<String> readFile(String relativePath) async {
    final file = File(p.join(projectDir.path, relativePath));
    return await file.readAsString();
  }

  /// Write a file to the project directory
  Future<void> writeFile(String relativePath, String content) async {
    final file = File(p.join(projectDir.path, relativePath));
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }
}
