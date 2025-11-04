import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

class InterfaceInputs
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

  InterfaceInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.projectName,
    required this.targetDir,
  });

  Future<InterfaceData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({'input': 'interface'}),
      fieldName: 'interface name',
      exampleName: 'Auth',
    );

    // Get location
    final InterfaceLocation location = await _getLocation();

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

    // Get component
    final NameComponent component = await _getComponent(location: location);

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
        MainConstants.interfaceSuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
      ],
      commandName: 'interface',
    );

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

    return InterfaceData(
      name: name,
      onPath: onPath,
      force: force,
      targetDir: targetDir,
      template: template,
      projectName: projectName,
      location: location,
      type: type,
      component: component,
      modelName: modelName,
      modelData: modelData,
    );
  }

  Future<InterfaceLocation> _getLocation() async {
    final argLocation = argResults['location'] as String?;

    // If not in interactive mode and no type specified, use default
    if (!isInteractiveMode && (argLocation == null || argLocation.isEmpty)) {
      return InterfaceLocation.domain;
    }

    if (argLocation != null && argLocation.isNotEmpty) {
      if (!InterfaceLocation.isValidKey(argLocation)) {
        throw ValidationException.invalidOption(
          'interface location',
          argLocation,
          InterfaceLocation.allKeys,
        );
      }
      return InterfaceLocation.fromKey(argLocation);
    }

    final options = InterfaceLocation.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'interface location'}),
      options,
      initialIndex: InterfaceLocation.domain.index,
    );

    return InterfaceLocation.values[selection];
  }

  Future<NameComponent> _getComponent({
    required InterfaceLocation location,
  }) async {
    switch (location) {
      case InterfaceLocation.domain:
        return NameComponent.interface;
      case InterfaceLocation.repositories:
        return NameComponent.repositoriesInterfaces;
      case InterfaceLocation.datasources:
        return NameComponent.datasourcesInterfaces;
    }
  }

  Future<InterfaceType> _getType() async {
    final typeArg = argResults['type'] as String?;

    // If not in interactive mode and no type specified, use default
    if (!isInteractiveMode && (typeArg == null || typeArg.isEmpty)) {
      return InterfaceType.empty;
    }

    if (typeArg != null && typeArg.isNotEmpty) {
      if (!InterfaceType.isValidKey(typeArg)) {
        throw ValidationException.invalidOption(
          'interface type',
          typeArg,
          InterfaceType.allKeys,
        );
      }
      return InterfaceType.fromKey(typeArg) ?? InterfaceType.empty;
    }

    final options = InterfaceType.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'interface type'}),
      options,
      initialIndex: InterfaceType.empty.index,
    );

    return InterfaceType.values[selection];
  }

  Future<String?> _getModelName(InterfaceType interfaceType) async {
    final modelArg = argResults['model'] as String?;

    // If not in interactive mode and no model specified, use default (null)
    if (!isInteractiveMode && (modelArg == null || modelArg.isEmpty)) {
      return null;
    }

    if (modelArg != null && modelArg.isNotEmpty) {
      if (interfaceType != InterfaceType.crud) {
        throw ValidationException.custom(
          'Model name can only be used with CRUD interfaces.\n'
          ' Please use --type crud to specify a CRUD interface.',
        );
      }
      await _validateModelName(modelArg);
      return modelArg;
    }

    if (interfaceType != InterfaceType.crud) return null;

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
}
