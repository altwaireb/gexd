import 'dart:io';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// EnvironmentValidatorService - Validate and manage project environment
///
/// This service handles:
/// - Dependency validation and installation
/// - Build runner setup and execution
/// - Project configuration validation
/// - Environment prerequisites checking
class EnvironmentValidatorService {
  final Logger _logger;

  EnvironmentValidatorService({Logger? logger}) : _logger = logger ?? Logger();

  /// Check if build_runner is available in the project
  Future<bool> hasBuildRunner() async {
    try {
      final pubspecFile = File(
        path.join(Directory.current.path, 'pubspec.yaml'),
      );
      if (!await pubspecFile.exists()) {
        return false;
      }

      final pubspecContent = await pubspecFile.readAsString();
      final pubspec = loadYaml(pubspecContent) as Map;

      final devDependencies = pubspec['dev_dependencies'] as Map?;
      return devDependencies?.containsKey('build_runner') == true;
    } catch (e) {
      _logger.err('Error checking build_runner: $e');
      return false;
    }
  }

  /// Check if specific dependencies are available
  Future<bool> hasDependencies(List<String> dependencies) async {
    try {
      final pubspecFile = File(
        path.join(Directory.current.path, 'pubspec.yaml'),
      );
      if (!await pubspecFile.exists()) {
        return false;
      }

      final pubspecContent = await pubspecFile.readAsString();
      final pubspec = loadYaml(pubspecContent) as Map;

      final deps = pubspec['dependencies'] as Map? ?? {};
      final devDeps = pubspec['dev_dependencies'] as Map? ?? {};

      for (final dependency in dependencies) {
        if (!deps.containsKey(dependency) && !devDeps.containsKey(dependency)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      _logger.err('Error checking dependencies: $e');
      return false;
    }
  }

  /// Install required dependencies for a model style
  Future<bool> installDependenciesForStyle(ModelStyle style) async {
    try {
      final dependencies = style.requiredDependencies;
      final devDependencies = style.requiredDevDependencies;

      if (dependencies.isEmpty && devDependencies.isEmpty) {
        return true; // No dependencies needed
      }

      _logger.info('Installing dependencies for ${style.displayName}...');

      // Install regular dependencies
      if (dependencies.isNotEmpty) {
        final depArgs = ['pub', 'add', ...dependencies];
        final depResult = await Process.run('dart', depArgs);

        if (depResult.exitCode != 0) {
          _logger.err('Failed to install dependencies: ${depResult.stderr}');
          return false;
        }
      }

      // Install dev dependencies
      if (devDependencies.isNotEmpty) {
        final devDepArgs = ['pub', 'add', '--dev', ...devDependencies];
        final devDepResult = await Process.run('dart', devDepArgs);

        if (devDepResult.exitCode != 0) {
          _logger.err(
            'Failed to install dev dependencies: ${devDepResult.stderr}',
          );
          return false;
        }
      }

      _logger.info('✅ Dependencies installed successfully');
      return true;
    } catch (e) {
      _logger.err('Error installing dependencies: $e');
      return false;
    }
  }

  /// Run build_runner for generated files
  Future<bool> runBuildRunner({List<String>? specificFiles}) async {
    final progress = _logger.progress('Running build_runner...');

    try {
      if (!await hasBuildRunner()) {
        progress.update('Installing build_runner dependency...');
        final installed = await _installBuildRunner();
        if (!installed) {
          progress.fail('Failed to install build_runner');
          return false;
        }
      }

      progress.update('Generating code files...');

      List<String> args;
      if (specificFiles != null && specificFiles.isNotEmpty) {
        // Run build_runner for specific files if supported
        args = ['run', 'build_runner', 'build', '--delete-conflicting-outputs'];
      } else {
        args = ['run', 'build_runner', 'build', '--delete-conflicting-outputs'];
      }

      final result = await Process.run('dart', args);

      if (result.exitCode != 0) {
        progress.fail('Build runner failed');
        _logger.err('Build runner error: ${result.stderr}');
        return false;
      }

      progress.complete('✅ Build runner completed successfully');
      return true;
    } catch (e) {
      progress.fail('Error running build_runner');
      _logger.err('Build runner error: $e');
      return false;
    }
  }

  /// Validate that all prerequisites are met for model generation
  Future<ValidationResult> validateEnvironmentForStyle(ModelStyle style) async {
    final issues = <String>[];
    final warnings = <String>[];

    // Check if we're in a Flutter/Dart project
    final pubspecFile = File(path.join(Directory.current.path, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) {
      issues.add('Not in a valid Dart/Flutter project (no pubspec.yaml found)');
      return ValidationResult(
        isValid: false,
        issues: issues,
        warnings: warnings,
      );
    }

    // Check required dependencies
    final hasRequiredDeps = await hasDependencies([
      ...style.requiredDependencies,
      ...style.requiredDevDependencies,
    ]);

    if (!hasRequiredDeps) {
      warnings.add(
        'Some required dependencies for ${style.displayName} are missing',
      );
    }

    // Check build_runner for styles that need it
    if (style.requiresBuildRunner) {
      final hasRunner = await hasBuildRunner();
      if (!hasRunner) {
        warnings.add(
          'build_runner is required for ${style.displayName} but not installed',
        );
      }
    }

    // Check Dart SDK version
    final dartVersion = await _getDartSdkVersion();
    if (dartVersion != null) {
      final version = _parseDartVersion(dartVersion);
      if (version != null && version < 2.17) {
        issues.add('Dart SDK 2.17+ is required, found $dartVersion');
      }
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      warnings: warnings,
    );
  }

  /// Auto-fix environment issues
  Future<bool> autoFixEnvironment(ModelStyle style) async {
    final progress = _logger.progress(
      'Auto-fixing environment for ${style.displayName}...',
    );

    try {
      // Install missing dependencies
      progress.update('Installing required dependencies...');
      final installed = await installDependenciesForStyle(style);
      if (!installed) {
        progress.fail('Failed to install dependencies');
        return false;
      }

      // Run pub get to ensure all dependencies are resolved
      progress.update('Resolving dependencies...');
      final pubGetResult = await Process.run('dart', ['pub', 'get']);
      if (pubGetResult.exitCode != 0) {
        progress.fail('Failed to resolve dependencies');
        _logger.err('pub get failed: ${pubGetResult.stderr}');
        return false;
      }

      progress.complete('✅ Environment auto-fix completed');
      return true;
    } catch (e) {
      progress.fail('Error auto-fixing environment');
      _logger.err('Error: $e');
      return false;
    }
  }

  /// Check if the project supports a specific model style
  Future<bool> supportsModelStyle(ModelStyle style) async {
    final validation = await validateEnvironmentForStyle(style);
    return validation.isValid;
  }

  /// Get recommended model style based on project setup
  Future<ModelStyle> getRecommendedModelStyle() async {
    // Check for existing patterns in the project
    final hasFreezed = await hasDependencies(['freezed_annotation']);
    if (hasFreezed) {
      return ModelStyle.freezed;
    }

    final hasJsonAnnotation = await hasDependencies(['json_annotation']);
    if (hasJsonAnnotation) {
      return ModelStyle.json;
    }

    return ModelStyle.plain; // Default fallback
  }

  /// Install build_runner if not present
  Future<bool> _installBuildRunner() async {
    try {
      final result = await Process.run('dart', [
        'pub',
        'add',
        '--dev',
        'build_runner',
      ]);
      return result.exitCode == 0;
    } catch (e) {
      _logger.err('Failed to install build_runner: $e');
      return false;
    }
  }

  /// Get Dart SDK version
  Future<String?> _getDartSdkVersion() async {
    try {
      final result = await Process.run('dart', ['--version']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Parse Dart version string to comparable number
  double? _parseDartVersion(String versionString) {
    try {
      final regex = RegExp(r'(\d+\.\d+)');
      final match = regex.firstMatch(versionString);
      if (match != null) {
        return double.parse(match.group(1)!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Result of environment validation
class ValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.issues,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasIssues => issues.isNotEmpty;
}
