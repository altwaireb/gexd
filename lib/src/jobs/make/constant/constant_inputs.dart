import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

/// Handles inputs for constant job
/// Gathers necessary information from command-line arguments
/// or interactively via prompts
/// Produces ConstantData for use in constant generation
class ConstantInputs
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

  ConstantInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<ConstantData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({'input': 'constant'}),
      fieldName: 'constant name',
      exampleName: 'App',
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
    final NameComponent component = NameComponent.coreConstants;

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
        MainConstants.constantsSuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
      ],
      commandName: 'constant',
      createNameSubfolder: false, // Constants go directly in constants folder
    );

    return ConstantData(
      name: name,
      onPath: onPath,
      force: force,
      targetDir: targetDir,
      template: template,
      component: component,
    );
  }
}
