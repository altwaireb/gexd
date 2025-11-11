import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

/// Handles inputs for screen job
/// Gathers necessary information from command-line arguments
/// or interactively via prompts
/// Produces ScreenData for use in screen generation
class ScreenInputs
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

  ScreenInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<ScreenData> handle() async {
    final name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({'input': 'screen'}),
      fieldName: 'screen name',
      exampleName: 'Login',
    );
    final screenType = await _getScreenType();
    final onPath = await getOnInput(
      prompt: prompt,
      promptMessage: MainConstants.onPathInput,
      fieldName: '--on path',
      exampleName: 'auth/user',
      maxDepth: MainConstants.maxPathDepth,
      confirmPrompt: MainConstants.askForOnPathPrompt,
    );
    final skipRoute = await _getSkipRoute();
    final modelName = await _getModelName(screenType);
    final hasModelFlag = await _getHasModelFlag(screenType);
    final entityName = await _getEntityName(screenType);
    final hasEntityFlag = await _getHasEntityFlag(screenType);

    // Validate that model and entity are not both specified
    _validateModelEntityConflict(
      modelName,
      entityName,
      hasModelFlag,
      hasEntityFlag,
    );
    final force = await getForceInput(
      prompt: prompt,
      confirmationMessage: MainConstants.askForOverwriteInput,
      defaultConfirmation: false,
      name: name,
      on: onPath,
      template: template,
      component: NameComponent.screen,
      targetDir: targetDir,
      expectedFiles: [
        MainConstants.controllerSuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
        MainConstants.viewSuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
        MainConstants.bindingSuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
      ],
      commandName: 'screen',
    );

    ModelDetectionData? modelData;

    // Check model only if modelName is provided
    if (modelName != null && modelName.isNotEmpty) {
      modelData = await ModelDetectionService.getModelData(
        modelName: modelName,
        template: template,
        basePath: targetDir,
        suffixes: ['Model'],
      );
    } else if (hasModelFlag == true) {
      modelData = await ModelDetectionService.getModelData(
        modelName: name,
        template: template,
        basePath: targetDir,
        suffixes: ['Model'],
      );

      // Validate that model exists when using --has-model
      if (!modelData.exists) {
        throw ModelNotFoundException.fromModelName(name, template);
      }
    }

    EntityDetectionData? entityData;

    // Check entity only if entityName is provided
    if (entityName != null && entityName.isNotEmpty) {
      entityData = await EntityDetectionService.getEntityData(
        entityName: entityName,
        template: template,
        basePath: targetDir,
        suffixes: ['Entity'],
      );
    } else if (hasEntityFlag == true) {
      entityData = await EntityDetectionService.getEntityData(
        entityName: name,
        template: template,
        basePath: targetDir,
        suffixes: ['Entity'],
      );

      // Validate that entity exists when using --has-entity
      if (!entityData.exists) {
        throw ValidationException.custom(
          'Entity "$name" not found in the project.\n'
          'Create it first with: gexd make entity $name',
        );
      }
    }

    return ScreenData(
      name: name,
      targetDir: targetDir,
      template: template,
      onPath: onPath,
      skipRoute: skipRoute,
      screenType: screenType,
      modelName: modelName,
      hasModelFlag: hasModelFlag,
      modelData: modelData,
      entityName: entityName,
      hasEntityFlag: hasEntityFlag,
      entityData: entityData,
      force: force,
    );
  }

  Future<ScreenType> _getScreenType() async {
    final typeArg = argResults['type'] as String?;

    // If not in interactive mode and no type specified, use default
    if (!isInteractiveMode && (typeArg == null || typeArg.isEmpty)) {
      return ScreenType.basic;
    }

    if (typeArg != null && typeArg.isNotEmpty) {
      if (!ScreenType.isValidKey(typeArg)) {
        throw ValidationException.invalidOption(
          'screen type',
          typeArg,
          ScreenType.allKeys,
        );
      }
      return ScreenType.fromKey(typeArg) ?? ScreenType.basic;
    }

    final options = ScreenType.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'screen type'}),
      options,
      initialIndex: ScreenType.basic.index,
    );

    return ScreenType.values[selection];
  }

  Future<bool> _getSkipRoute() async {
    final skipRouteArg = argResults['skip-route'] as bool? ?? false;

    // If --skip-route flag is explicitly provided, return true
    if (skipRouteArg) {
      return true;
    }

    // If not in interactive mode and no skip-route flag specified, use default (false)
    if (!isInteractiveMode) return false;

    final confirm = await prompt.confirm(
      MainConstants.defaultRoutePrompt,
      defaultValue: true,
    );

    return !confirm; // Invert because prompt asks to add routes
  }

  Future<String?> _getModelName(ScreenType screenType) async {
    final modelArg = argResults['model'] as String?;

    // If not in interactive mode and no model specified, use default (null)
    if (!isInteractiveMode && (modelArg == null || modelArg.isEmpty)) {
      return null;
    }

    if (modelArg != null && modelArg.isNotEmpty) {
      if (screenType != ScreenType.withState) {
        throw ValidationException.custom(
          'Model name is required for stateful screens.\n'
          ' Please use --type withState to specify a stateful screen.',
        );
      }
      await _validateModelName(modelArg);
      return modelArg;
    }

    if (screenType != ScreenType.withState) return null;

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

  Future<bool> _getHasModelFlag(ScreenType screenType) async {
    final hasModelArg = argResults['has-model'] as bool?;

    if (hasModelArg != null && hasModelArg) {
      if (screenType != ScreenType.withState) {
        throw ValidationException.custom(
          'The --has-model flag is only applicable for stateful screens.\n'
          ' Please use --type withState to specify a stateful screen.',
        );
      }
      return true;
    }

    // If not in interactive mode and no has-model flag specified, use default (false)
    if (!isInteractiveMode) return false;

    if (screenType != ScreenType.withState) return false;

    final confirm = await prompt.confirm(
      MainConstants.askForHasModelInput,
      defaultValue: false,
    );

    return confirm;
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

  Future<String?> _getEntityName(ScreenType screenType) async {
    final entityArg = argResults['entity'] as String?;

    // If not in interactive mode and no entity specified, use default (null)
    if (!isInteractiveMode && (entityArg == null || entityArg.isEmpty)) {
      return null;
    }

    if (entityArg != null && entityArg.isNotEmpty) {
      if (screenType != ScreenType.withState) {
        throw ValidationException.custom(
          'Entity name can only be used with withState screens.\n'
          'Please use --type withState to specify a withState screen.',
        );
      }
      await _validateEntityName(entityArg);
      return entityArg;
    }

    if (screenType != ScreenType.withState) return null;

    final askForEntity = await prompt.confirm(
      'Do you want to specify an entity for this screen?',
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

  Future<bool> _getHasEntityFlag(ScreenType screenType) async {
    final hasEntityArg = argResults['has-entity'] as bool?;

    // If has-entity flag is provided, validate for consistency
    if (hasEntityArg != null && hasEntityArg) {
      if (screenType != ScreenType.withState) {
        throw ValidationException.custom(
          '--has-entity flag can only be used with withState screens.\n'
          'Please use --type withState to specify a withState screen.',
        );
      }
      return hasEntityArg;
    }

    // If not in interactive mode and no has-entity flag specified, use default (false)
    if (!isInteractiveMode) return false;

    if (screenType != ScreenType.withState) return false;

    final confirm = await prompt.confirm(
      'Use entity class with same name as screen?',
      defaultValue: false,
    );

    return confirm;
  }

  /// Validate that model and entity are not both specified
  void _validateModelEntityConflict(
    String? modelName,
    String? entityName,
    bool hasModelFlag,
    bool hasEntityFlag,
  ) {
    final hasModel =
        (modelName != null && modelName.isNotEmpty) || hasModelFlag;
    final hasEntity =
        (entityName != null && entityName.isNotEmpty) || hasEntityFlag;

    if (hasModel && hasEntity) {
      throw ValidationException.custom(
        'Cannot specify both model and entity for the same screen.\n'
        'Please choose either --model/--has-model or --entity/--has-entity.',
      );
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
