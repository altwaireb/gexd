import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

class ControllerInputs
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

  ControllerInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<ControllerData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({
        'input': 'controller',
      }),
      fieldName: 'controller name',
      exampleName: 'Auth',
    );

    // Get location
    final ControllerLocation location = await _getLocation();

    // Get onPath
    final String? onPath = await getOnInput(
      prompt: prompt,
      promptMessage: MainConstants.onPathInput,
      fieldName: '--on path',
      exampleName: 'auth/user',
      maxDepth: MainConstants.maxPathDepth,
      confirmPrompt: MainConstants.askForOnPathPrompt,
    );

    // Validate incompatible options
    if (location == ControllerLocation.screen &&
        onPath != null &&
        onPath.isNotEmpty) {
      throw ValidationException.custom(
        'The --on option cannot be used with screen location. '
        'Use --on-screen to specify the screen name instead.',
      );
    }

    // Get component
    final NameComponent component = await _getComponent(location: location);

    final String? screenName = await _getScreenNameInput(
      location: location,
      component: component,
    );

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
        MainConstants.bindingSingleSuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
      ],
      commandName: 'controller',
      hasSubPath: location == ControllerLocation.screen,
      nameSubPath: location == ControllerLocation.screen ? 'controllers' : null,
      baseName: screenName, // Pass screen name for path calculation
    );

    return ControllerData(
      name: name,
      onPath: onPath,
      force: force,
      targetDir: targetDir,
      template: template,
      location: location,
      component: component,
      screenName: screenName,
    );
  }

  Future<ControllerLocation> _getLocation() async {
    final argLocation = argResults['location'] as String?;

    // If not in interactive mode and no type specified, use default
    if (!isInteractiveMode && (argLocation == null || argLocation.isEmpty)) {
      return ControllerLocation.shared;
    }

    if (argLocation != null && argLocation.isNotEmpty) {
      if (!ControllerLocation.isValidKey(argLocation)) {
        throw ValidationException.invalidOption(
          'controller location',
          argLocation,
          ControllerLocation.allKeys,
        );
      }
      return ControllerLocation.fromKey(argLocation);
    }

    final options = ControllerLocation.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'controller location'}),
      options,
      initialIndex: ControllerLocation.shared.index,
    );

    return ControllerLocation.values[selection];
  }

  Future<NameComponent> _getComponent({
    required ControllerLocation location,
  }) async {
    switch (location) {
      case ControllerLocation.shared:
        return NameComponent.screenControllers;
      case ControllerLocation.screen:
        return NameComponent.screen;
    }
  }

  Future<String?> _getScreenNameInput({
    required ControllerLocation location,
    required NameComponent component,
  }) async {
    final argScreenName = argResults['on-screen'] as String?;
    if (location == ControllerLocation.screen) {
      // If not in interactive mode and no screen name specified, throw error
      if (!isInteractiveMode &&
          (argScreenName == null || argScreenName.isEmpty)) {
        throw ValidationException.missingRequiredOption(
          'screen name',
          '--on-screen',
        );
      }

      // If screen name provided via arg, use it
      if (argScreenName != null && argScreenName.isNotEmpty) {
        await _validateScreenName(
          argScreenName,
          toUserMessage: false,
          template: template,
          formatOnly: true,
        );
        return argScreenName;
      }

      // Prompt for screen name
      final screenName = await prompt.input(
        MainConstants.nameInput.formatWith({'input': 'screen name'}),
        validator: (value) {
          _validateScreenName(
            value,
            toUserMessage: true,
            template: template,
            formatOnly: true,
          );
          return null;
        },
      );

      return screenName.trim();
    }
    return null;
  }

  Future<void> _validateScreenName(
    String screenName, {
    bool formatOnly = false,
    bool toUserMessage = false,
    ProjectTemplate? template,
  }) async {
    final validator = FieldValidator('screen name', example: 'home');

    // Always do format validation first
    validator.notEmpty(screenName, toUserMessage);
    validator.pathCaseWithDepth(
      screenName,
      maxDepth: 3,
      example: 'auth/user',
      toUserMessage: toUserMessage,
    );

    // Skip existence check if formatOnly is true (for interactive sync validation)
    if (!formatOnly) {
      await validator.existingScreenPath(
        screenName,
        toUserMessage: toUserMessage,
        template: template,
      );
    }
  }
}
