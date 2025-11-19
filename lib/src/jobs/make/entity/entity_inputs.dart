import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

/// Handles inputs for entity job
/// Gathers necessary information from command-line arguments
/// or interactively via prompts
/// Produces EntityData for use in entity generation
class EntityInputs
    with
        HasArgResults,
        HasName,
        HasInteractiveMode,
        HasNameInput,
        HasOnInput,
        HasForceFlag {
  @override
  final ArgResults argResults;
  final PromptServiceInterface prompt;
  final ProjectTemplate template;
  final Directory targetDir;

  EntityInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<EntityData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({'input': 'entity'}),
      fieldName: 'entity name',
      exampleName: 'User',
    );

    // Get input source type
    final EntityInputSourceType inputSourceType =
        await _getEntityInputSourceTypeInput();

    // Get file path if needed
    final String? filePath = await _getFileInput(inputSourceType);

    final String? urlPath = await _getUrlInput(inputSourceType);

    // Validate incompatible input source options
    _validateInputSourceOptions(filePath, urlPath);

    // Get style
    final EntityStyle style = await _getEntityStyleInput();

    // Get withModel flag
    final bool withModel = await _getWithModelInput();

    // Get equatable
    final bool equatable = await _getEquatableInput();

    // Get onPath
    final String? onPath = await getOnInput(
      prompt: prompt,
      promptMessage: MainConstants.onPathInput,
      fieldName: '--on path',
      exampleName: 'auth/user',
      maxDepth: MainConstants.maxPathDepth,
      confirmPrompt: MainConstants.askForOnPathPrompt,
    );

    // Get component
    final NameComponent component = NameComponent.entities;

    // Get force
    final bool force = await getForceInput(
      prompt: prompt,
      confirmationMessage: MainConstants.askForOverwriteInput,
      defaultConfirmation: false,
      name: name,
      on: onPath,
      template: template,
      component: component,
      targetDir: targetDir,
      expectedFiles: [
        '${StringHelpers.toSnakeCase(name)}_entity.dart',
        if (withModel) '${StringHelpers.toSnakeCase(name)}_model.dart',
      ],
      commandName: 'entity',
    );

    return EntityData(
      name: name,
      targetDir: targetDir,
      template: template,
      inputSourceType: inputSourceType,
      filePath: filePath,
      urlPath: urlPath,
      style: style,
      withModel: withModel,
      equatable: equatable,
      onPath: onPath,
      force: force,
      component: component,
    );
  }

  /// Get entity input source type input
  Future<EntityInputSourceType> _getEntityInputSourceTypeInput() async {
    final argFile = argResults['file'] as String?;
    final argUrl = argResults['url'] as String?;

    // Check for conflicts first before determining type
    if (argFile != null &&
        argFile.isNotEmpty &&
        argUrl != null &&
        argUrl.isNotEmpty) {
      throw ValidationException.custom(
        'Cannot specify both --file and --url options. '
        'Please choose only one input source.',
      );
    }

    if (argFile != null && argFile.isNotEmpty) {
      return EntityInputSourceType.file;
    }

    if (argUrl != null && argUrl.isNotEmpty) {
      return EntityInputSourceType.url;
    }

    // If not in interactive mode and no file/url specified, default to template
    if (!isInteractiveMode && (argFile == null && argUrl == null)) {
      return EntityInputSourceType.template;
    }

    final options = EntityInputSourceType.toList;
    final selection = await prompt.select(
      'Choose entity input source:',
      options,
      initialIndex: EntityInputSourceType.template.index,
    );
    return EntityInputSourceType.values[selection];
  }

  /// Get file path input
  Future<String?> _getFileInput(EntityInputSourceType inputSourceType) async {
    if (inputSourceType == EntityInputSourceType.file) {
      final argFile = argResults['file'] as String?;
      if (argFile != null && argFile.isNotEmpty) {
        _validateFilePath(argFile, toUserMessage: false);
        return argFile;
      }

      final filePath = await prompt.input(
        'Enter the path to the entity definition file:\n'
        '(e.g., assets/models/user.json)',
        validator: (value) {
          _validateFilePath(value, toUserMessage: false);
          return null;
        },
      );
      return filePath;
    } else {
      return null;
    }
  }

  /// Get URL path input
  Future<String?> _getUrlInput(EntityInputSourceType inputSourceType) async {
    if (inputSourceType == EntityInputSourceType.url) {
      final argUrl = argResults['url'] as String?;
      if (argUrl != null && argUrl.isNotEmpty) {
        _validateUrlPath(argUrl, toUserMessage: false);
        return argUrl;
      }

      final urlPath = await prompt.input(
        'Enter the URL to fetch the entity definition from:\n'
        '(e.g., https://api.example.com/user/123)',
        validator: (value) {
          _validateUrlPath(value, toUserMessage: false);
          return null;
        },
      );
      return urlPath;
    } else {
      return null;
    }
  }

  Future<EntityStyle> _getEntityStyleInput() async {
    final argStyle = argResults['style'] as String?;

    if (argStyle != null && argStyle.isNotEmpty) {
      return EntityStyle.fromKey(argStyle);
    }

    // If not in interactive mode and no style specified, use default
    if (!isInteractiveMode) {
      return EntityStyle.immutable;
    }

    final options = EntityStyle.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'entity style'}),
      options,
      initialIndex: EntityStyle.immutable.index,
    );
    return EntityStyle.values[selection];
  }

  Future<bool> _getWithModelInput() async {
    final argWithModel = argResults['with-model'] as bool? ?? false;
    if (!isInteractiveMode) {
      return argWithModel;
    }

    if (argWithModel) return true;

    return await prompt.confirm(
      'Generate corresponding data model?',
      defaultValue: false,
    );
  }

  Future<bool> _getEquatableInput() async {
    final argEquatable = argResults['equatable'] as bool? ?? true;
    if (!isInteractiveMode) {
      return argEquatable;
    }

    return await prompt.confirm(
      'Use Equatable for value comparison?',
      defaultValue: true,
    );
  }

  // validation helper methods

  // validate file path
  Future<void> _validateFilePath(
    String value, {
    bool toUserMessage = false,
  }) async {
    final validator = FieldValidator(
      'file',
      example: 'assets/models/user.json',
    );
    validator.notEmpty(value, toUserMessage);
    validator.fileExists(value, toUserMessage: toUserMessage);
    validator.jsonFile(value, toUserMessage: toUserMessage);
    validator.safeFilePath(value, toUserMessage: toUserMessage);
    validator.fileSize(value, toUserMessage: toUserMessage);
  }

  // Validate URL path
  Future<void> _validateUrlPath(
    String value, {
    bool toUserMessage = false,
  }) async {
    final validator = FieldValidator(
      'URL',
      example: 'https://api.example.com/user/123',
    );
    validator.notEmpty(value, toUserMessage);
    validator.validUrl(value, toUserMessage: toUserMessage);
    validator.httpUrl(value, toUserMessage: toUserMessage);
    validator.publicUrl(value, toUserMessage: toUserMessage);
  }

  // Validate incompatible input source options
  void _validateInputSourceOptions(String? filePath, String? urlPath) {
    // Check if both file and url are provided
    if (filePath != null &&
        filePath.isNotEmpty &&
        urlPath != null &&
        urlPath.isNotEmpty) {
      throw ValidationException.custom(
        'Cannot specify both --file and --url options. '
        'Please choose only one input source.',
      );
    }
  }
}
