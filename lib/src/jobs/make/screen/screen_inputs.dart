import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

class ScreenInputs with HasArgResults, HasName, HasInteractiveMode {
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
    final name = await _getName();
    final screenType = await _getScreenType();
    final onPath = await _getOnPath();
    final skipRoute = await _getSkipRoute();
    final modelName = await _getModelName(screenType);
    final hasModelFlag = await _getHasModelFlag(screenType);

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
    );
  }

  Future<String> _getName() async {
    final nameArg = nameFromArgs;

    if (nameArg != null && nameArg.isNotEmpty) {
      _validateName(nameArg);
      return nameArg;
    }

    return await prompt.input(
      ScreenConstants.screenNamePrompt,
      validator: (value) {
        _validateName(value, toUserMessage: true);
        return null;
      },
    );
  }

  Future<String?> _getOnPath() async {
    final pathArg = argResults['on'] as String?;

    // If not in interactive mode and no path specified, use default (null)
    if (!isInteractiveMode && (pathArg == null || pathArg.isEmpty)) {
      return null;
    }

    if (pathArg != null && pathArg.isNotEmpty) {
      _validateOnPath(pathArg);
      return pathArg;
    }

    final askForPath = await prompt.confirm(
      ScreenConstants.askForOnPathPrompt,
      defaultValue: false,
    );

    if (!askForPath) return null;

    final customPath = await prompt.input(
      ScreenConstants.onPathPrompt,
      validator: (value) {
        _validateOnPath(value);
        return null;
      },
    );
    return customPath.trim().isEmpty ? null : customPath;
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
      ScreenConstants.screenTypePrompt,
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
      ScreenConstants.defaultRoutePrompt,
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
      ScreenConstants.askForModelNamePrompt,
      defaultValue: false,
    );

    if (!askForModel) return null;

    final nameModel = await prompt.input(
      ScreenConstants.modelNamePrompt,
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
      ScreenConstants.askForHasModelPrompt,
      defaultValue: false,
    );

    return confirm;
  }

  // section for Validations

  void _validateName(String value, {bool toUserMessage = false}) {
    final exampleName = 'Login';
    final validator = FieldValidator('screen name', example: exampleName);
    validator.notEmpty(value, toUserMessage);
    validator.pascalCase(value, exampleName, toUserMessage);
    validator.validSuffix(value, exampleName, toUserMessage);
  }

  void _validateOnPath(String value, {bool toUserMessage = false}) {
    if (value.isEmpty) return; // Empty is valid

    final pathValidator = FieldValidator('--on path', example: 'auth/user');
    pathValidator.notEmpty(value, toUserMessage);
    pathValidator.pathCaseWithDepth(
      value,
      maxDepth: ScreenConstants.maxPathDepth,
      example: 'auth/user/registration',
      toUserMessage: toUserMessage,
    );
  }

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
}
