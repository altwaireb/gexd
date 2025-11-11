import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

/// Handles inputs for util job
/// Gathers necessary information from command-line arguments
/// or interactively via prompts
/// Produces UtilData for use in util generation
class UtilInputs
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

  UtilInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<UtilData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({'input': 'util'}),
      fieldName: 'util name',
      exampleName: 'Validation',
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
    final NameComponent component = NameComponent.coreUtils;

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
        MainConstants.utilSuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
      ],
      commandName: 'util',
      createNameSubfolder: false, // Utils go directly in utils folder
    );

    return UtilData(
      name: name,
      onPath: onPath,
      force: force,
      targetDir: targetDir,
      template: template,
      component: component,
    );
  }
}
