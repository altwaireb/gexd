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

  /// Format code
  // @override
  Future<void> formatCode(String projectName) async {
    final progress = _logger.progress('Formatting code...');

    try {
      final result = await Process.run(
        'dart',
        ['format', '.'],
        runInShell: true,
        workingDirectory: projectName,
      );

      if (result.exitCode == 0) {
        progress.complete('Code formatted successfully');
      } else {
        progress.update('Code formatting completed with warnings');
        _logger.warn('Format warnings: ${result.stderr}');
      }
    } catch (e) {
      progress.update('Code formatting skipped');
      _logger.warn('Code formatting failed: $e');
      // Don't throw exception here because formatting is not critical
    }
  }

  /// Run final pub get
  // @override
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
  // @override
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
  // @override
  Future<void> analyzeCode(String projectName) async {
    final progress = _logger.progress('Analyzing code...');

    try {
      final result = await Process.run(
        'dart',
        ['analyze', '.'],
        runInShell: true,
        workingDirectory: projectName,
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
  // @override
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
