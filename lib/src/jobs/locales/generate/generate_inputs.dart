import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';
import 'package:path/path.dart' as path;

/// Handles input arguments and prompts for generating localization files
/// Validates inputs and returns a [GenerateData] object
/// Throws [ValidationException] if any validation fails
class GenerateInputs {
  final ArgResults argResults;
  final PromptServiceInterface prompt;
  final Directory targetDir;
  final ProjectTemplate template;

  GenerateInputs(
    this.argResults, {
    required this.prompt,
    required this.targetDir,
    required this.template,
  });

  Future<GenerateData> handle() async {
    // Get input directory (locales folder)
    final String from = await _getFromInput();

    // Get output path for generated file
    final String outputPath = await _getOutputPathInput();

    // Get locale key style (dot notation vs snake_case)
    final LocaleKeyStyle keyStyle = await _getLocaleKeyStyleInput();

    // Get sort keys option
    final bool sortKeys = await _getSortKeysInput();

    // Get force overwrite option
    final bool force = await _getForceInput(outputPath);

    final ProjectTemplate template = this.template;

    final NameComponent component = NameComponent.locales;

    return GenerateData(
      from: from,
      outputPath: outputPath,
      targetDir: targetDir,
      template: template,
      component: component,
      keyStyle: keyStyle,
      sortKeys: sortKeys,
      force: force,
    );
  }

  Future<String> _getFromInput() async {
    final argInputDir = argResults.rest.isNotEmpty == true
        ? argResults.rest.first
        : null;

    if (argInputDir != null && argInputDir.isNotEmpty) {
      _validateDirectory(argInputDir, targetDir: targetDir);
      return argInputDir;
    }

    final inputDir = await prompt.input(
      'Locales folder path (e.g., assets/locales):',
      defaultValue: 'assets/locales',
      validator: (value) {
        try {
          _validateDirectory(value, toUserMessage: true, targetDir: targetDir);
          return null;
        } catch (e) {
          return e.toString();
        }
      },
    );

    return inputDir;
  }

  Future<String> _getOutputPathInput() async {
    final argOutput = argResults['output'] as String?;
    if (argOutput != null && argOutput.isNotEmpty) {
      return argOutput;
    }

    // Generate output path based on template and component
    final component = NameComponent.locales;
    final basePath = ArchitectureCoordinator.getComponentPath(
      component,
      template,
    );
    final outputPath = path.join(basePath, 'translations.g.dart');

    return outputPath;
  }

  Future<LocaleKeyStyle> _getLocaleKeyStyleInput() async {
    final argKeyStyle = argResults['key-style'] as String?;
    if (argKeyStyle != null && argKeyStyle.isNotEmpty) {
      if (LocaleKeyStyle.isValidKey(argKeyStyle)) {
        return LocaleKeyStyle.fromKey(argKeyStyle)!;
      }
      throw ValidationException.invalidOption(
        'key-style',
        argKeyStyle,
        LocaleKeyStyle.allKeys,
      );
    }

    final options = LocaleKeyStyle.toList;
    final selectedIndex = await prompt.select(
      'Select locale key style:',
      options,
      initialIndex: LocaleKeyStyle.dot.index,
    );

    return LocaleKeyStyle.values[selectedIndex];
  }

  Future<bool> _getSortKeysInput() async {
    final argSort = argResults['sort-keys'] as bool?;
    if (argSort != null) {
      return argSort;
    }

    return await prompt.confirm(
      'Sort locale keys alphabetically?',
      defaultValue: true,
    );
  }

  Future<bool> _getForceInput(String outputPath) async {
    final argForce = argResults['force'] as bool?;
    if (argForce != null) {
      return argForce;
    }

    // Check if output file exists
    final outputFile = File(path.join(targetDir.path, outputPath));
    if (!outputFile.existsSync()) {
      return false; // No need to overwrite if file doesn't exist
    }

    return await prompt.confirm(
      'Output file already exists. Overwrite?',
      defaultValue: false,
    );
  }

  void _validateDirectory(
    String value, {
    bool toUserMessage = false,
    required Directory targetDir,
  }) {
    final fullPath = path.join(targetDir.path, value);
    final validator = FieldValidator('directory', example: 'assets/locales');

    validator.notEmpty(value, toUserMessage);
    validator.safeFilePath(fullPath, toUserMessage: toUserMessage);

    // Check if directory exists
    final dir = Directory(fullPath);
    if (!dir.existsSync()) {
      if (toUserMessage) {
        throw ValidationException.directoryNotFound(fullPath);
      }
    }

    // Check if directory contains JSON files
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
    if (files.isEmpty) {
      if (toUserMessage) {
        throw ValidationException.custom(
          'No JSON files found in directory: $fullPath',
          code: ValidationErrorCode.notFound,
          field: 'locales',
          value: fullPath,
        );
      }
    }
  }
}
