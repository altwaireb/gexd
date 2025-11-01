import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

class BindingInputs
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

  BindingInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<BindingData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({'input': 'binding'}),
      fieldName: 'binding name',
      exampleName: 'Auth',
    );

    // Get location
    final BindingLocation location = await _getLocation();

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
    if (location == BindingLocation.screen &&
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
      commandName: 'binding',
      hasSubPath: location == BindingLocation.screen,
      nameSubPath: location == BindingLocation.screen ? 'bindings' : null,
      baseName: screenName, // Pass screen name for path calculation
      createNameSubfolder: false, // Bindings go directly in bindings folder
    );

    return BindingData(
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

  Future<BindingLocation> _getLocation() async {
    final argLocation = argResults['location'] as String?;

    // If not in interactive mode and no type specified, use default
    if (!isInteractiveMode && (argLocation == null || argLocation.isEmpty)) {
      return BindingLocation.shared;
    }

    if (argLocation != null && argLocation.isNotEmpty) {
      if (!BindingLocation.isValidKey(argLocation)) {
        throw ValidationException.invalidOption(
          'binding location',
          argLocation,
          BindingLocation.allKeys,
        );
      }
      return BindingLocation.fromKey(argLocation);
    }

    final options = BindingLocation.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'binding location'}),
      options,
      initialIndex: BindingLocation.core.index,
    );

    return BindingLocation.values[selection];
  }

  Future<NameComponent> _getComponent({
    required BindingLocation location,
  }) async {
    switch (location) {
      case BindingLocation.core:
        return NameComponent.coreBindings;
      case BindingLocation.shared:
        return NameComponent.bindings;
      case BindingLocation.screen:
        return NameComponent.screenBindings;
    }
  }

  Future<String?> _getScreenNameInput({
    required BindingLocation location,
    required NameComponent component,
  }) async {
    final argScreenName = argResults['on-screen'] as String?;
    if (location == BindingLocation.screen) {
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
