import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Handles input arguments and prompts for initializing a project
/// Validates inputs and returns an [InitData] object
/// Throws [ValidationException] if any validation fails
class InitInputs {
  final ArgResults argResults;
  final PromptServiceInterface prompt;
  final Logger _logger = Logger();
  final bool skipValidation;
  final String currentDir;

  InitInputs({
    required this.argResults,
    required this.prompt,
    required this.skipValidation,
    required this.currentDir,
  });

  Future<InitData> handle() async {
    // Validate that we're in a Flutter project (skip in test mode)
    if (!skipValidation) {
      await _validateFlutterProject(currentDir);
    } else {
      _logger.detail('🧪 Skipping Flutter project validation (test mode)');
    }
    final name = await _getProjectName(currentDir);
    final template = await _getTemplate();
    final full = await _isFullStructure();

    return InitData(
      name: name,
      template: template,
      full: full,
      targetDir: currentDir,
    );
  }

  /// Get project name from directory or pubspec.yaml
  Future<String> _getProjectName(String currentDir) async {
    try {
      // Try to get name from pubspec.yaml first
      final pubspecFile = File(path.join(currentDir, 'pubspec.yaml'));
      if (await pubspecFile.exists()) {
        final content = await pubspecFile.readAsString();
        final nameMatch = RegExp(r'name:\s*(.+)').firstMatch(content);
        if (nameMatch != null) {
          final name = nameMatch.group(1)?.trim();
          if (name != null && name.isNotEmpty) {
            _logger.infoMessage(CommandMessages.projectNameFromPubspec, {
              'projectName': name,
            });
            return name;
          }
        }
      }

      // Fallback to directory name
      final dirName = path.basename(currentDir);
      _logger.infoMessage(CommandMessages.projectNameFromDirectory, {
        'projectName': dirName,
      });
      return dirName;
    } catch (e) {
      // Final fallback
      final dirName = path.basename(currentDir);
      _logger.warnMessage(CommandMessages.projectNameFallback, {
        'projectName': dirName,
      });
      return dirName;
    }
  }

  /// Get project template [ProjectTemplate] from --template option
  /// or prompt the user
  Future<ProjectTemplate> _getTemplate() async {
    final templateArg = argResults['template'] as String?;
    if (templateArg != null && templateArg.isNotEmpty) {
      if (ProjectTemplate.isValidKey(templateArg)) {
        return ProjectTemplate.fromKey(templateArg);
      } else {
        throw ValidationException.invalidOption(
          'template',
          templateArg,
          ProjectTemplate.allKeys,
        );
      }
    }

    final options = ProjectTemplate.toList;
    final index = await prompt.select(
      'Select project template',
      options,
      initialIndex: ProjectTemplate.getx.index,
    );
    return ProjectTemplate.values[index];
  }

  Future<bool> _isFullStructure() async {
    final fullArg = argResults['full'] as bool?;
    if (fullArg == true) return true;

    final hasArgs =
        argResults.rest.isNotEmpty ||
        argResults.options.any((key) => key != 'full');

    if (hasArgs) return false;

    return await prompt.confirm(
      'Do you want to add all template-specific directories?',
      defaultValue: false,
    );
  }

  /// Validate that we're in a valid Flutter project directory
  Future<void> _validateFlutterProject(String directory) async {
    final pubspecFile = File(path.join(directory, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) {
      throw ConfigProjectException.missing('pubspec.yaml');
    }

    // Check if pubspec contains flutter dependencies
    final content = await pubspecFile.readAsString();
    if (!content.contains('flutter:')) {
      throw ConfigProjectException.invalidFormat(
        'pubspec.yaml',
        content,
        expectedFormat: 'A Flutter project with flutter dependencies',
      );
    }

    // Check if lib directory exists
    final libDir = Directory(path.join(directory, 'lib'));
    if (!await libDir.exists()) {
      throw ValidationException.notFound('lib directory', identifier: 'lib/');
    }

    _logger.successMessage(ValidationMessages.flutterProjectValidated);
  }
}
