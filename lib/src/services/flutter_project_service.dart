import 'dart:io';
import 'package:gexd/src/core/exceptions/project_creation_exception.dart';
import 'package:gexd/src/services/interfaces/flutter_project_service_interface.dart';
import 'package:mason_logger/mason_logger.dart';

/// Flutter project creation service
class FlutterProjectService implements FlutterProjectServiceInterface {
  final Logger _logger;

  FlutterProjectService({Logger? logger}) : _logger = logger ?? Logger();

  /// Create new Flutter project
  @override
  Future<void> createProject({
    required String projectName,
    required String organization,
    required String description,
    required List<String> platforms,
  }) async {
    final progress = _logger.progress('Creating Flutter project...');

    try {
      final args = [
        'create',
        projectName,
        '--org',
        organization,
        '--description',
        description,
        '--platforms',
        platforms.join(','),
      ];

      _logger.detail('Running: flutter ${args.join(' ')}');

      final result = await Process.run('flutter', args, runInShell: true);

      if (result.exitCode != 0) {
        throw ProjectCreationException.fileSystemError(
          'flutter create',
          result.stderr.toString(),
        );
      }

      progress.complete('Flutter project created successfully');
      _logger.detail('Flutter output: ${result.stdout}');
    } catch (e) {
      progress.fail('Failed to create Flutter project');
      if (e is ProjectCreationException) {
        rethrow;
      }
      throw ProjectCreationException.templateProcessingFailed(
        'Flutter',
        e.toString(),
      );
    }
  }

  /// Check if Flutter CLI is available
  Future<bool> isFlutterAvailable() async {
    try {
      final result = await Process.run('flutter', [
        '--version',
      ], runInShell: true);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get Flutter version
  Future<String?> getFlutterVersion() async {
    try {
      final result = await Process.run('flutter', [
        '--version',
      ], runInShell: true);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');
        if (lines.isNotEmpty) {
          return lines.first.trim();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
