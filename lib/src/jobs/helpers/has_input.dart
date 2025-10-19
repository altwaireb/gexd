import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

/// Mixin to provide access to ArgResults
mixin HasArgResults {
  ArgResults get argResults;
}

/// Mixin to handle name argument
mixin HasName on HasArgResults {
  String? get nameFromArgs =>
      argResults.rest.isNotEmpty ? argResults.rest.first : null;
}

/// Mixin to determine if in interactive mode
mixin HasInteractiveMode on HasName {
  bool get isInteractiveMode => nameFromArgs == null;
}

/// Mixin to handle name input
/// Requires HasName and HasInteractiveMode
mixin HasNameInput on HasName, HasInteractiveMode {
  Future<String> getNameInput({
    required PromptServiceInterface prompt,
    required String promptMessage,
    required String fieldName,
    required String exampleName,
    String? defaultValue,
  }) async {
    final nameArg = nameFromArgs;

    if (nameArg != null && nameArg.isNotEmpty) {
      _validateName(nameArg, fieldName, exampleName, toUserMessage: false);
      return nameArg;
    }

    return await prompt.input(
      promptMessage,
      validator: (value) {
        _validateName(value, fieldName, exampleName, toUserMessage: false);
        return null;
      },
    );
  }

  void _validateName(
    String value,
    String fieldName,
    String exampleName, {
    bool toUserMessage = false,
  }) {
    final validator = FieldValidator(fieldName, example: exampleName);
    validator.notEmpty(value, toUserMessage);
    validator.pascalCase(value, exampleName, toUserMessage);
    validator.validSuffix(value, exampleName, toUserMessage);
  }
}

/// Mixin to handle 'on' path input
/// Requires HasArgResults and HasInteractiveMode
/// to be mixed in
mixin HasOnInput on HasArgResults, HasInteractiveMode {
  Future<String?> getOnInput({
    required PromptServiceInterface prompt,
    required String promptMessage,
    required String fieldName,
    required String exampleName,
    required int maxDepth,
    required String confirmPrompt,
    String? defaultValue,
  }) async {
    final pathArg = argResults['on'] as String?;

    // If not in interactive mode and no path specified, use default (null)
    if (!isInteractiveMode && (pathArg == null || pathArg.isEmpty)) {
      return null;
    }

    if (pathArg != null && pathArg.isNotEmpty) {
      _validateOnPath(
        pathArg,
        fieldName,
        exampleName,
        maxDepth,
        toUserMessage: false,
      );
      return pathArg;
    }

    final askForPath = await prompt.confirm(confirmPrompt, defaultValue: false);

    if (!askForPath) return null;

    final customPath = await prompt.input(
      promptMessage,
      validator: (value) {
        _validateOnPath(
          value,
          fieldName,
          exampleName,
          maxDepth,
          toUserMessage: false,
        );
        return null;
      },
    );
    return customPath.trim().isEmpty ? null : customPath;
  }

  void _validateOnPath(
    String value,
    String fieldName,
    String exampleName,
    int maxDepth, {
    bool toUserMessage = false,
  }) {
    if (value.isEmpty) return; // Empty is valid

    final pathValidator = FieldValidator(fieldName, example: exampleName);
    pathValidator.notEmpty(value, toUserMessage);
    pathValidator.pathCaseWithDepth(
      value,
      maxDepth: maxDepth,
      example: exampleName,
      toUserMessage: toUserMessage,
    );
  }
}
