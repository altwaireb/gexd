import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

/// Handles inputs for middleware job
/// Gathers necessary information from command-line arguments
/// or interactively via prompts
/// Produces MiddlewareData for use in middleware generation
class MiddlewareInputs
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

  MiddlewareInputs(
    this.argResults, {
    required this.prompt,
    required this.template,
    required this.targetDir,
  });

  Future<MiddlewareData> handle() async {
    // Get name
    final String name = await getNameInput(
      prompt: prompt,
      promptMessage: MainConstants.nameInput.formatWith({
        'input': 'middleware',
      }),
      fieldName: 'middleware name',
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
    final NameComponent component = NameComponent.coreMiddleware;

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
        MainConstants.middlewareSuffix.formatWith({
          'name': StringHelpers.toSnakeCase(name),
        }),
      ],
      commandName: 'middleware',
      createNameSubfolder:
          false, // Middleware files go directly in middleware folder
    );

    return MiddlewareData(
      name: name,
      onPath: onPath,
      force: force,
      targetDir: targetDir,
      template: template,
      component: component,
    );
  }
}
