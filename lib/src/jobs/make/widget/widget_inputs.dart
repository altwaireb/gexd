import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

/// Handles inputs for screen job
/// Gathers necessary information from command-line arguments
/// or interactively via prompts
/// Produces WidgetData for use in widget generation
class WidgetInputs
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

  WidgetInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<WidgetData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({'input': 'widget'}),
      fieldName: 'widget name',
      exampleName: 'CustomButton',
    );

    // Get location
    final WidgetLocation location = await _getLocation();

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
    if (location == WidgetLocation.screen &&
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
        MainConstants.widgetSingleSuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
      ],
      commandName: 'widget',
      hasSubPath: location == WidgetLocation.screen,
      nameSubPath: location == WidgetLocation.screen ? 'widgets' : null,
      // Pass screen name for path calculation
      baseName: screenName,
      // Widgets go directly in widgets folder
      createNameSubfolder: false,
    );

    return WidgetData(
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

  Future<WidgetLocation> _getLocation() async {
    final argLocation = argResults['location'] as String?;

    if (argLocation != null && argLocation.isNotEmpty) {
      if (!WidgetLocation.isValidKey(argLocation)) {
        throw ValidationException.invalidOption(
          'widget location',
          argLocation,
          WidgetLocation.allKeys,
        );
      }
      return WidgetLocation.fromKey(argLocation);
    }

    // If not in interactive mode and no location specified, use default
    if (!isInteractiveMode) {
      return WidgetLocation.shared;
    }

    final options = WidgetLocation.toList;
    final selection = await prompt.select(
      MainConstants.chooseInput.formatWith({'input': 'widget location'}),
      options,
      initialIndex: WidgetLocation.shared.index,
    );

    return WidgetLocation.values[selection];
  }

  Future<NameComponent> _getComponent({
    required WidgetLocation location,
  }) async {
    switch (location) {
      case WidgetLocation.shared:
        return NameComponent.widgets;
      case WidgetLocation.screen:
        return NameComponent.screenWidgets;
    }
  }

  Future<String?> _getScreenNameInput({
    required WidgetLocation location,
    required NameComponent component,
  }) async {
    final argScreenName = argResults['on-screen'] as String?;
    if (location == WidgetLocation.screen) {
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
