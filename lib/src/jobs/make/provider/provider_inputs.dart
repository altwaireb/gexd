import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

/// Handles inputs for model job
/// Gathers necessary information from command-line arguments
/// or interactively via prompts
/// Produces ProviderData for use in provider generation
class ProviderInputs
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

  ProviderInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<ProviderData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({'input': 'provider'}),
      fieldName: 'provider name',
      exampleName: 'Auth',
    );

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
    final NameComponent component = NameComponent.providers;

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
        MainConstants.serviceSuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
      ],
      commandName: 'provider',
      createNameSubfolder: false, // Providers go directly in providers folder
    );

    return ProviderData(
      name: name,
      onPath: onPath,
      force: force,
      targetDir: targetDir,
      template: template,
      component: component,
    );
  }
}
