import 'dart:io';
import 'package:gexd/src/core/exceptions/project_creation_exception.dart';
import 'package:gexd/src/services/interfaces/post_generation_service_interface.dart';
import 'package:mason_logger/mason_logger.dart';

/// Post-generation processing service
class PostGenerationService implements PostGenerationServiceInterface {
  final Logger _logger;

  PostGenerationService({Logger? logger}) : _logger = logger ?? Logger();

  /// Run post-generation operations
  @override
  Future<void> runPostGeneration(String projectName) async {
    await formatCode(projectName);
    await validateProject(projectName);
    await runPubGet(projectName);
  }

  /// Format code for entire project
  @override
  Future<void> formatCode(String projectPath) async {
    final progress = _logger.progress('Formatting code...');

    try {
      // Check if dart is available in PATH
      final dartExists = await _isDartAvailable();
      if (!dartExists) {
        progress.update('Code formatting skipped (Dart SDK not found in PATH)');
        _logger.detail('Dart SDK not found in PATH. Code formatting skipped.');
        return;
      }

      // Check if we're in a valid Flutter/Dart project
      final projectDir = Directory(projectPath);
      final pubspecFile = File('${projectDir.path}/pubspec.yaml');
      if (!await pubspecFile.exists()) {
        progress.update('Code formatting skipped (not in project root)');
        _logger.detail('pubspec.yaml not found. Code formatting skipped.');
        return;
      }

      final result = await Process.run(
        'dart',
        ['format', '.'],
        runInShell: true,
        workingDirectory: projectPath,
      );

      if (result.exitCode == 0) {
        progress.complete('Code formatted successfully');
      } else {
        progress.update('Code formatting completed with warnings');
        _logger.warn('Format warnings: ${result.stderr}');
      }
    } catch (e) {
      progress.fail('Code formatting skipped');
      _logger.info('');
      _logger.warn('Code formatting failed: $e');
      // Don't throw exception here because formatting is not critical
    }
  }

  /// Format specific files only (more efficient for generated files)
  @override
  Future<void> formatSpecificFiles(
    List<String> filePaths,
    String projectPath,
  ) async {
    if (filePaths.isEmpty) return;

    final progress = _logger.progress('Formatting generated files...');

    try {
      // Check if dart is available in PATH
      final dartExists = await _isDartAvailable();
      if (!dartExists) {
        progress.update('Code formatting skipped (Dart SDK not found in PATH)');
        _logger.detail('Dart SDK not found in PATH. Code formatting skipped.');
        return;
      }

      // Filter existing files
      final existingFiles = <String>[];
      for (final filePath in filePaths) {
        final file = File(filePath);
        if (await file.exists()) {
          existingFiles.add(filePath);
        }
      }

      if (existingFiles.isEmpty) {
        progress.update('No files to format');
        return;
      }

      // Format each file individually
      final result = await Process.run(
        'dart',
        ['format', ...existingFiles],
        runInShell: true,
        workingDirectory: projectPath,
      );

      if (result.exitCode == 0) {
        progress.complete(
          'Generated files formatted successfully (${existingFiles.length} file${existingFiles.length != 1 ? 's' : ''})',
        );
      } else {
        progress.update('File formatting completed with warnings');
        _logger.warn('Format warnings: ${result.stderr}');
      }
    } catch (e) {
      progress.fail('File formatting skipped');
      _logger.info('');
      _logger.warn('File formatting failed: $e');
      // Don't throw exception here because formatting is not critical
    }
  }

  /// Check if dart command is available
  Future<bool> _isDartAvailable() async {
    try {
      final result = await Process.run('dart', ['--version'], runInShell: true);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Run final pub get
  @override
  Future<void> runPubGet(String projectName) async {
    final progress = _logger.progress('Getting final dependencies...');

    try {
      final result = await Process.run(
        'flutter',
        ['pub', 'get'],
        runInShell: true,
        workingDirectory: projectName,
      );

      if (result.exitCode == 0) {
        progress.complete('Final dependencies retrieved successfully');
      } else {
        progress.fail('Failed to get final dependencies');
        throw ProjectCreationException.dependencyInstallationFailed(
          'pub get failed: ${result.stderr}',
        );
      }
    } catch (e) {
      progress.fail('Failed to get final dependencies');
      if (e is ProjectCreationException) {
        rethrow;
      }
      throw ProjectCreationException.dependencyInstallationFailed(e.toString());
    }
  }

  /// Validate project
  @override
  Future<void> validateProject(String projectName) async {
    final progress = _logger.progress('Validating project structure...');

    try {
      final requiredFiles = [
        '$projectName/pubspec.yaml',
        '$projectName/lib/main.dart',
        '$projectName/test/widget_test.dart',
      ];

      for (final filePath in requiredFiles) {
        if (!File(filePath).existsSync()) {
          throw ProjectCreationException.fileSystemError(
            'validation',
            'Missing required file: $filePath',
          );
        }
      }

      // Check pubspec.yaml content
      final pubspecContent = await File(
        '$projectName/pubspec.yaml',
      ).readAsString();
      if (!pubspecContent.contains('flutter:')) {
        throw ProjectCreationException.configurationError(
          'pubspec.yaml',
          'missing Flutter configuration',
        );
      }

      progress.complete('Project validation successful');
    } catch (e) {
      progress.fail('Project validation failed');
      if (e is ProjectCreationException) {
        rethrow;
      }
      throw ProjectCreationException.fileSystemError(
        'validation',
        e.toString(),
      );
    }
  }

  /// Run code analysis
  @override
  Future<void> analyzeCode(String projectPath) async {
    final progress = _logger.progress('Analyzing code...');

    try {
      // Check if dart is available in PATH
      final dartExists = await _isDartAvailable();
      if (!dartExists) {
        progress.update('Code analysis skipped (Dart SDK not found in PATH)');
        return;
      }

      final result = await Process.run(
        'dart',
        ['analyze', '.'],
        runInShell: true,
        workingDirectory: projectPath,
      );

      if (result.exitCode == 0) {
        progress.complete('Code analysis passed');
      } else {
        progress.update('Code analysis completed with issues');
        _logger.warn('Analysis issues found: ${result.stdout}');
      }
    } catch (e) {
      progress.update('Code analysis skipped');
      _logger.warn('Code analysis failed: $e');
    }
  }

  /// Run tests
  @override
  Future<void> runTests(String projectName) async {
    final progress = _logger.progress('Running tests...');

    try {
      final result = await Process.run(
        'flutter',
        ['test'],
        runInShell: true,
        workingDirectory: projectName,
      );

      if (result.exitCode == 0) {
        progress.complete('All tests passed');
      } else {
        progress.fail('Some tests failed');
        _logger.warn('Test failures: ${result.stdout}');
      }
    } catch (e) {
      progress.update('Tests skipped');
      _logger.warn('Test execution failed: $e');
    }
  }
}
