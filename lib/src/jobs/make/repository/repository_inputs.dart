import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

/// Handles inputs for model job
/// Gathers necessary information from command-line arguments
/// or interactively via prompts
/// Produces RepositoryData for use in repository generation
class RepositoryInputs
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
  final String projectName;
  final Directory targetDir;

  RepositoryInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.projectName,
    required this.targetDir,
  });

  Future<RepositoryData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({
        'input': 'repository',
      }),
      fieldName: 'repository name',
      exampleName: 'Auth',
    );

    // Get location

    // Get onPath
    final String? onPath = await getOnInput(
      prompt: prompt,
      promptMessage: MainConstants.onPathInput,
      fieldName: '--on path',
      exampleName: 'auth/user',
      maxDepth: MainConstants.maxPathDepth,
      confirmPrompt: MainConstants.askForOnPathPrompt,
    );

    // Get type
    final type = await _getType();

    // Get model name
    final modelName = await _getModelName(type);

    // Get entity name
    final entityName = await _getEntityName(type);

    // Validate that model and entity are not both specified
    _validateModelEntityConflict(modelName, entityName);

    // Get component
    final NameComponent component = NameComponent.repositories;

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
        MainConstants.repositorySuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
      ],
      commandName: 'repository',
    );

    // Get interface
    final bool hasInterface = await _getHasInterface();

    // Get model data if model name is provided
    ModelDetectionData? modelData;
    if (modelName != null && modelName.isNotEmpty) {
      modelData = await ModelDetectionService.getModelData(
        modelName: modelName,
        template: template,
        basePath: targetDir,
        suffixes: ['Model'],
      );
    }

    // Get entity data if entity name is provided
    EntityDetectionData? entityData;
    if (entityName != null && entityName.isNotEmpty) {
      entityData = await EntityDetectionService.getEntityData(
        entityName: entityName,
        template: template,
        basePath: targetDir,
        suffixes: ['Entity'],
      );
    }

    return RepositoryData(
      name: name,
      onPath: onPath,
      force: force,
      targetDir: targetDir,
      template: template,
      projectName: projectName,
      type: type,
      component: component,
      hasInterface: hasInterface,
      modelName: modelName,
      modelData: modelData,
      entityName: entityName,
      entityData: entityData,
    );
  }

  Future<RepositoryType> _getType() async {
    final typeArg = argResults['type'] as String?;

    if (typeArg != null && typeArg.isNotEmpty) {
      if (!RepositoryType.isValidKey(typeArg)) {
        throw ValidationException.invalidOption(
          'repository type',
          typeArg,
          RepositoryType.allKeys,
        );
      }
      return RepositoryType.fromKey(typeArg) ?? RepositoryType.empty;
    }

    // If not in interactive mode and no type specified, use default
    if (!isInteractiveMode) {
      return RepositoryType.empty;
    }

    final options = RepositoryType.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'repository type'}),
      options,
      initialIndex: RepositoryType.empty.index,
    );

    return RepositoryType.values[selection];
  }

  Future<bool> _getHasInterface() async {
    final hasInterfaceArg = argResults['interface'] as bool?;

    // If not in interactive mode and no interface specified, use default
    if (!isInteractiveMode && (hasInterfaceArg == null)) {
      return false;
    }

    if (hasInterfaceArg != null) {
      return hasInterfaceArg;
    }

    final confirmation = await prompt.confirm(
      MainConstants.askForHasInterfaceInput,
      defaultValue: false,
    );

    return confirmation;
  }

  Future<String?> _getModelName(RepositoryType repositoryType) async {
    final modelArg = argResults['model'] as String?;

    // If not in interactive mode and no model specified, use default (null)
    if (!isInteractiveMode && (modelArg == null || modelArg.isEmpty)) {
      return null;
    }

    if (modelArg != null && modelArg.isNotEmpty) {
      if (repositoryType != RepositoryType.crud) {
        throw ValidationException.custom(
          'Model name can only be used with CRUD repositories.\n'
          ' Please use --type crud to specify a CRUD repository.',
        );
      }
      await _validateModelName(modelArg);
      return modelArg;
    }

    if (repositoryType != RepositoryType.crud) return null;

    final askForModel = await prompt.confirm(
      MainConstants.askForModelNameInput,
      defaultValue: false,
    );

    if (!askForModel) return null;

    final nameModel = await prompt.input(
      MainConstants.nameInput.formatWith({'input': 'model'}),
      validator: (value) {
        if (value.trim().isEmpty) return null; // Allow empty
        _validateModelName(value, toUserMessage: true);
        return null;
      },
    );
    return nameModel.trim().isEmpty ? null : nameModel;
  }

  Future<String?> _getEntityName(RepositoryType repositoryType) async {
    final entityArg = argResults['entity'] as String?;

    // If not in interactive mode and no entity specified, use default (null)
    if (!isInteractiveMode && (entityArg == null || entityArg.isEmpty)) {
      return null;
    }

    if (entityArg != null && entityArg.isNotEmpty) {
      if (repositoryType != RepositoryType.crud) {
        throw ValidationException.custom(
          'Entity name can only be used with CRUD repositories.\n'
          ' Please use --type crud to specify a CRUD repository.',
        );
      }
      await _validateEntityName(entityArg);
      return entityArg;
    }

    if (repositoryType != RepositoryType.crud) return null;

    final askForEntity = await prompt.confirm(
      'Do you want to specify an entity for this repository?',
      defaultValue: false,
    );

    if (!askForEntity) return null;

    final nameEntity = await prompt.input(
      MainConstants.nameInput.formatWith({'input': 'entity'}),
      validator: (value) {
        if (value.trim().isEmpty) return null; // Allow empty
        _validateEntityName(value, toUserMessage: true);
        return null;
      },
    );
    return nameEntity.trim().isEmpty ? null : nameEntity;
  }

  /// Validate that model and entity are not both specified
  void _validateModelEntityConflict(String? modelName, String? entityName) {
    if (modelName != null &&
        modelName.isNotEmpty &&
        entityName != null &&
        entityName.isNotEmpty) {
      throw ValidationException.custom(
        'Cannot specify both --model and --entity flags simultaneously.\n'
        'Please choose either a model or an entity for the repository.',
      );
    }
  }

  // section for Validations

  Future<void> _validateModelName(
    String value, {
    bool toUserMessage = false,
  }) async {
    final exampleModel = 'User';
    final validator = FieldValidator('model name', example: exampleModel);
    validator.notEmpty(value, toUserMessage);
    validator.pascalCase(value, exampleModel, toUserMessage);

    // Check if model exists in the project
    final exists = await ModelDetectionService.exists(
      modelName: value,
      template: template,
      basePath: targetDir,
      suffixes: ['Model'],
    );
    if (!exists) {
      throw ModelNotFoundException.fromModelName(value, template);
    }
  }

  Future<void> _validateEntityName(
    String value, {
    bool toUserMessage = false,
  }) async {
    final exampleEntity = 'User';
    final validator = FieldValidator('entity name', example: exampleEntity);
    validator.notEmpty(value, toUserMessage);
    validator.pascalCase(value, exampleEntity, toUserMessage);

    // Check if entity exists in the project (only for Clean Architecture)
    if (template == ProjectTemplate.clean) {
      final exists = await EntityDetectionService.exists(
        entityName: value,
        template: template,
        basePath: targetDir,
        suffixes: ['Entity'],
      );
      if (!exists) {
        throw ValidationException.custom(
          'Entity "$value" not found in the project.\n'
          'Create it first with: gexd make entity $value',
        );
      }
    }
  }
}
