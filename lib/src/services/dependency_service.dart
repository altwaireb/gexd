import 'dart:io';
import 'package:gexd/src/core/enums/project_template.dart';
import 'package:gexd/src/core/exceptions/project_creation_exception.dart';
import 'package:gexd/src/services/interfaces/dependency_service_interface.dart';
import 'package:mason_logger/mason_logger.dart';

/// Dependency management service
class DependencyService implements DependencyServiceInterface {
  final Logger _logger;

  DependencyService({Logger? logger}) : _logger = logger ?? Logger();

  /// Add dependencies based on template type
  @override
  Future<void> addDependencies({
    required String projectPath,
    required ProjectTemplate template,
  }) async {
    final progress = _logger.progress('Adding essential dependencies...');

    try {
      // Essential dependencies for all templates
      await _addDependency(projectPath, 'get');

      // JSON model generation dependencies
      await _addDependency(projectPath, 'json_annotation');

      // Dev dependencies
      await _addDevDependency(projectPath, 'build_runner');
      await _addDevDependency(projectPath, 'json_serializable');

      progress.complete('Essential dependencies added successfully');
    } catch (e) {
      progress.fail('Failed to add dependencies');
      throw ProjectCreationException.dependencyInstallationFailed(e.toString());
    }
  }

  /// Add dependency
  Future<void> _addDependency(String projectPath, String dependency) async {
    final result = await Process.run(
      'dart',
      ['pub', 'add', dependency],
      runInShell: true,
      workingDirectory: projectPath,
    );

    if (result.exitCode != 0) {
      throw ProjectCreationException.dependencyInstallationFailed(
        'Failed to add dependency $dependency: ${result.stderr}',
      );
    }

    _logger.detail('Added dependency: $dependency');
  }

  /// Add dev dependency
  Future<void> _addDevDependency(String projectPath, String dependency) async {
    final result = await Process.run(
      'dart',
      ['pub', 'add', 'dev:$dependency'],
      runInShell: true,
      workingDirectory: projectPath,
    );

    if (result.exitCode != 0) {
      throw ProjectCreationException.dependencyInstallationFailed(
        'Failed to add dev dependency $dependency: ${result.stderr}',
      );
    }

    _logger.detail('Added dev dependency: $dependency');
  }

  /// Run pub get to update dependencies
  @override
  Future<void> pubGet(String projectPath) async {
    final result = await Process.run(
      'dart',
      ['pub', 'get'],
      runInShell: true,
      workingDirectory: projectPath,
    );

    if (result.exitCode != 0) {
      throw ProjectCreationException.dependencyInstallationFailed(
        'Failed to run pub get: ${result.stderr}',
      );
    }

    _logger.detail('Successfully ran pub get');
  }
}
