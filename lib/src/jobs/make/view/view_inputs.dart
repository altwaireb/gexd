import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

class ViewInputs
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

  ViewInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<ViewData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({'input': 'view'}),
      fieldName: 'view name',
      exampleName: 'Auth',
    );

    // Get location
    final ViewLocation location = await _getLocation();

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
    if (location == ViewLocation.screen &&
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
      commandName: 'view',
      hasSubPath: location == ViewLocation.screen,
      nameSubPath: location == ViewLocation.screen ? 'views' : null,
      baseName: screenName, // Pass screen name for path calculation
    );

    return ViewData(
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

  Future<ViewLocation> _getLocation() async {
    final argLocation = argResults['location'] as String?;

    // If not in interactive mode and no type specified, use default
    if (!isInteractiveMode && (argLocation == null || argLocation.isEmpty)) {
      return ViewLocation.shared;
    }

    if (argLocation != null && argLocation.isNotEmpty) {
      if (!ViewLocation.isValidKey(argLocation)) {
        throw ValidationException.invalidOption(
          'view location',
          argLocation,
          ViewLocation.allKeys,
        );
      }
      return ViewLocation.fromKey(argLocation);
    }

    final options = ViewLocation.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'view location'}),
      options,
      initialIndex: ViewLocation.shared.index,
    );

    return ViewLocation.values[selection];
  }

  Future<NameComponent> _getComponent({required ViewLocation location}) async {
    switch (location) {
      case ViewLocation.shared:
        return NameComponent.screenViews;
      case ViewLocation.screen:
        return NameComponent.screen;
    }
  }

  Future<String?> _getScreenNameInput({
    required ViewLocation location,
    required NameComponent component,
  }) async {
    final argScreenName = argResults['on-screen'] as String?;
    if (location == ViewLocation.screen) {
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
