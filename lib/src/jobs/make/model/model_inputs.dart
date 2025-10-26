import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

class ModelInputs
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

  ModelInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<ModelData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({'input': 'model'}),
      fieldName: 'model name',
      exampleName: 'User',
    );

    // Get input source type
    final ModelInputSourceType inputSourceType =
        await _getModelInputSourceTypeInput();

    // Get file path if needed
    final String? filePath = await _getFileInput(inputSourceType);

    final String? urlPath = await _getUrlInput(inputSourceType);

    // Validate incompatible input source options
    _validateInputSourceOptions(filePath, urlPath);

    // Get style
    final ModelStyle style = await _getModelStyleInput(inputSourceType);

    // Get starterTemplate
    final ModelStarterTemplate starterTemplate =
        await _getModelStarterTemplateInput(inputSourceType, style);

    // Get custom fields if using custom template
    final List<CustomField> customFields = await _getCustomFieldsInput(
      inputSourceType,
      starterTemplate,
    );

    // Get immutable
    final bool immutable = await _getImmutableInput();

    // Get copyWith
    final bool copyWith = await _getCopyWithInput();

    // Get equatable
    final bool equatable = await _getEquatableInput();

    // Validate style-specific feature compatibility
    _validateStyleCompatibility(style, immutable, copyWith, equatable);

    // Get relationshipsInFolder
    final bool relationshipsInFolder = await _getRelationshipsInFolderInput();

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
    final NameComponent component = NameComponent.models;

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
        MainConstants.modelSuffix.formatWith({'name': name}),
        MainConstants.modelSuffixEndingModel.formatWith({'name': name}),
      ],
      commandName: 'model',
    );

    return ModelData(
      name: name,
      targetDir: targetDir,
      template: template,
      inputSourceType: inputSourceType,
      filePath: filePath,
      urlPath: urlPath,
      style: style,
      starterTemplate: starterTemplate,
      customFields: customFields,
      immutable: immutable,
      copyWith: copyWith,
      equatable: equatable,
      relationshipsInFolder: relationshipsInFolder,
      onPath: onPath,
      force: force,
      component: component,
    );
  }

  /// Get model input source type input
  /// Returns [ModelInputSourceType]
  /// Prompts the user to select an input source type if not provided in arguments
  Future<ModelInputSourceType> _getModelInputSourceTypeInput() async {
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
      return ModelInputSourceType.file;
    }

    if (argUrl != null && argUrl.isNotEmpty) {
      return ModelInputSourceType.url;
    }

    // If not in interactive mode and no file/url specified, default to template
    if (!isInteractiveMode && (argFile == null && argUrl == null)) {
      return ModelInputSourceType.template;
    }

    final options = ModelInputSourceType.toList;
    final selection = await prompt.select(
      MainConstants.modelInputSourceTypePrompt,
      options,
      initialIndex: ModelInputSourceType.template.index,
    );
    return ModelInputSourceType.values[selection];
  }

  /// Get file path input
  /// Returns [String?]
  /// Prompts the user to enter a file path if the input source type is file
  Future<String?> _getFileInput(ModelInputSourceType inputSourceType) async {
    if (inputSourceType == ModelInputSourceType.file) {
      final argFile = argResults['file'] as String?;
      if (argFile != null && argFile.isNotEmpty) {
        _validateFilePath(argFile, toUserMessage: false);
        return argFile;
      }

      final filePath = await prompt.input(
        'Enter the path to the model definition file:\n'
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
  /// Returns [String?]
  /// Prompts the user to enter a URL path if the input source type is url
  Future<String?> _getUrlInput(ModelInputSourceType inputSourceType) async {
    if (inputSourceType == ModelInputSourceType.url) {
      final argUrl = argResults['url'] as String?;
      if (argUrl != null && argUrl.isNotEmpty) {
        _validateUrlPath(argUrl, toUserMessage: false);
        return argUrl;
      }

      final urlPath = await prompt.input(
        'Enter the URL to fetch the model definition from:\n'
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

  Future<ModelStyle> _getModelStyleInput(
    ModelInputSourceType inputSourceType,
  ) async {
    final argStyle = argResults['style'] as String?;
    if (argStyle != null && argStyle.isNotEmpty) {
      return ModelStyle.fromKey(argStyle);
    }
    final options = ModelStyle.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'model style'}),
      options,
      initialIndex: ModelStyle.plain.index,
    );
    return ModelStyle.values[selection];
  }

  Future<ModelStarterTemplate> _getModelStarterTemplateInput(
    ModelInputSourceType inputSourceType,
    ModelStyle style,
  ) async {
    if (inputSourceType != ModelInputSourceType.template) {
      return ModelStarterTemplate.basic; // Default for non-template sources
    }

    final argTemplate = argResults['template'] as String?;
    if (argTemplate != null && argTemplate.isNotEmpty) {
      return ModelStarterTemplate.fromKey(argTemplate);
    }

    final options = ModelStarterTemplate.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'starter template'}),
      options,
      initialIndex: ModelStarterTemplate.basic.index,
    );
    return ModelStarterTemplate.values[selection];
  }

  Future<bool> _getImmutableInput() async {
    final argImmutable = argResults['immutable'] as bool? ?? false;
    if (!isInteractiveMode) {
      return argImmutable;
    }

    if (argImmutable) return true;

    return await prompt.confirm(
      'Make the model immutable?',
      defaultValue: false,
    );
  }

  Future<bool> _getCopyWithInput() async {
    final argCopyWith = argResults['copyWith'] as bool? ?? false;
    if (!isInteractiveMode) {
      return argCopyWith;
    }

    if (argCopyWith) return true;

    return await prompt.confirm('Add copyWith method?', defaultValue: false);
  }

  Future<bool> _getEquatableInput() async {
    final argEquatable = argResults['equatable'] as bool? ?? false;
    if (!isInteractiveMode) {
      return argEquatable;
    }

    if (argEquatable) return true;

    return await prompt.confirm(
      'Use Equatable for value comparison?',
      defaultValue: false,
    );
  }

  Future<bool> _getRelationshipsInFolderInput() async {
    final argRelationshipsInFolder =
        argResults['relationships-in-folder'] as bool? ?? true;
    if (!isInteractiveMode) {
      return argRelationshipsInFolder;
    }

    return await prompt.confirm(
      'Generate relationships in separate folder?',
      defaultValue: true,
    );
  }

  /// Get custom fields for custom template
  /// Returns [List<CustomField>]
  /// Only prompts if using template source with custom starter template
  Future<List<CustomField>> _getCustomFieldsInput(
    ModelInputSourceType inputSourceType,
    ModelStarterTemplate starterTemplate,
  ) async {
    // Only collect custom fields for template source with custom starter
    if (inputSourceType != ModelInputSourceType.template ||
        starterTemplate != ModelStarterTemplate.custom) {
      return [];
    }

    return await _buildCustomFieldsInteractively();
  }

  /// Interactive custom field builder with counter logic
  Future<List<CustomField>> _buildCustomFieldsInteractively() async {
    if (!isInteractiveMode) {
      // Return default fields for non-interactive mode with custom template
      return _getDefaultCustomFields();
    }

    final List<CustomField> fields = [];
    int fieldCount = 0;

    // No need for extra prompts, just start building

    bool continueAdding = true;

    while (continueAdding) {
      fieldCount++;

      final field = await _promptForSingleField(fieldCount, fields);
      if (field != null) {
        fields.add(field);
        // Field added successfully - continue to next
      }

      // After first field, ask if they want to continue
      if (fieldCount >= 1) {
        continueAdding = await _askToContinueAddingFields();
      }
    }

    _displayFieldsSummary(fields);
    return fields;
  }

  /// Prompt user for a single field
  Future<CustomField?> _promptForSingleField(
    int count,
    List<CustomField> existingFields,
  ) async {
    // Get field name
    final name = await _promptFieldName(existingFields);
    if (name == null || name.isEmpty) {
      return null;
    }

    // Get field type
    final type = await _promptFieldType();
    if (type == null) {
      return null;
    }

    return CustomField.fromInput(name: name, type: type);
  }

  /// Prompt for field name with duplicate check
  Future<String?> _promptFieldName(List<CustomField> existingFields) async {
    while (true) {
      final name = await prompt.input(
        'Enter field name:',
        validator: (value) {
          if (value.trim().isEmpty) {
            return 'Field name cannot be empty';
          }

          final normalizedName = _toCamelCase(value.trim());
          if (existingFields.any(
            (f) => f.name.toLowerCase() == normalizedName.toLowerCase(),
          )) {
            return 'Field "$normalizedName" already exists';
          }

          return null;
        },
      );

      if (name.isNotEmpty) {
        return _toCamelCase(name.trim());
      }
    }
  }

  /// Prompt for field type selection
  Future<FieldType?> _promptFieldType() async {
    final types = FieldType.values;
    final options = types
        .map((type) => '${type.displayName.padRight(20)} - ${type.description}')
        .toList();

    final selection = await prompt.select(
      'Select field type:',
      options,
      initialIndex: 0,
    );

    return types[selection];
  }

  /// Ask if user wants to continue adding fields
  Future<bool> _askToContinueAddingFields() async {
    return await prompt.confirm(
      'Do you want to add another field?',
      defaultValue: true,
    );
  }

  /// Display summary of all fields
  void _displayFieldsSummary(List<CustomField> fields) {
    if (fields.isEmpty) {
      return;
    }

    // Summary will be displayed by the job during execution
  }

  /// Get default custom fields for non-interactive mode
  List<CustomField> _getDefaultCustomFields() {
    return [
      CustomField.fromInput(name: 'id', type: FieldType.integer),
      CustomField.fromInput(name: 'name', type: FieldType.string),
      CustomField.fromInput(name: 'createdAt', type: FieldType.dateTime),
    ];
  }

  /// Convert string to camelCase
  String _toCamelCase(String input) {
    if (input.isEmpty) return input;

    final words = input.split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return input;

    String result = words[0].toLowerCase();
    for (int i = 1; i < words.length; i++) {
      final word = words[i];
      if (word.isNotEmpty) {
        result += word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
    }

    return result;
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

    // Check for conflicting template option with file/url
    final argTemplate = argResults['template'] as String?;
    final hasTemplateArg =
        argTemplate != null && argTemplate != ModelStarterTemplate.basic.key;

    if (hasTemplateArg && (filePath != null || urlPath != null)) {
      throw ValidationException.custom(
        'Cannot use --template option with --file or --url. '
        'Template is only used when no external source is specified.',
      );
    }
  }

  // Validate style-specific feature compatibility
  void _validateStyleCompatibility(
    ModelStyle style,
    bool immutable,
    bool copyWith,
    bool equatable,
  ) {
    // Freezed already provides copyWith and equality
    if (style == ModelStyle.freezed && copyWith) {
      throw ValidationException.custom(
        'Freezed models automatically provide copyWith functionality. '
        'Remove the --copyWith flag when using freezed style.',
      );
    }

    if (style == ModelStyle.freezed && equatable) {
      throw ValidationException.custom(
        'Freezed models automatically provide value equality. '
        'Remove the --equatable flag when using freezed style.',
      );
    }

    // Warn about redundant immutable with copyWith for plain style
    if (style == ModelStyle.plain && !immutable && copyWith) {
      throw ValidationException.custom(
        'copyWith method is typically used with immutable models. '
        'Consider adding --immutable flag or use a different style.',
      );
    }
  }
}
