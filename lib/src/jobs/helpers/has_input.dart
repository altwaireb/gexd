import 'dart:io';

import 'package:args/args.dart';
import 'package:gexd/gexd.dart';
import 'package:path/path.dart' as path;

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
    validator.minLength(value, 3, toUserMessage);
    validator.maxLength(value, 30, toUserMessage);
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

mixin HasForceFlag on HasArgResults, HasInteractiveMode {
  Future<bool> getForceInput({
    required PromptServiceInterface prompt,
    required String confirmationMessage,
    required bool defaultConfirmation,
    required String name,
    required String? on,
    required ProjectTemplate template,
    required NameComponent component,
    required Directory targetDir,
    required List<String> expectedFiles,
    required String commandName,
    // Optional parameters for flexible path handling
    bool hasSubPath = false,
    String? nameSubPath,
    String? baseName, // For screen bindings, this would be the screen name
    bool createNameSubfolder = true, // Whether to create subfolder with name
  }) async {
    final forceArg = argResults['force'] as bool?;
    // If --force flag is explicitly provided, return true
    if (forceArg == true) {
      return true;
    }

    // If not in interactive mode and no force flag specified, check for existing files
    if (!isInteractiveMode) {
      final existingFiles = await _findExistingFiles(
        name: name,
        on: on,
        template: template,
        targetDir: targetDir,
        checkFiles: expectedFiles,
        component: component,
        hasSubPath: hasSubPath,
        nameSubPath: nameSubPath,
        baseName: baseName,
        createNameSubfolder: createNameSubfolder,
      );
      if (existingFiles.isNotEmpty) {
        throw ValidationException.custom(
          'Screen files already exist. Use --force flag to overwrite:\n'
          '${existingFiles.map((f) => '  • $f').join('\n')}\n\n'
          'Example: gexd make $commandName $name --force',
        );
      }
      return false;
    }

    // Check if any files already exist
    final existingFiles = await _findExistingFiles(
      name: name,
      on: on,
      template: template,
      targetDir: targetDir,
      checkFiles: expectedFiles,
      component: component,
      hasSubPath: hasSubPath,
      nameSubPath: nameSubPath,
      baseName: baseName,
      createNameSubfolder: createNameSubfolder,
    );

    // If no files exist, no need to force
    if (existingFiles.isEmpty) {
      return false;
    }

    // Ask user if they want to overwrite existing files
    final filesMessage = existingFiles.length == 1
        ? 'The following file already exists:\n${existingFiles.first}'
        : 'The following files already exist:\n${existingFiles.map((f) => '  • $f').join('\n')}';

    print('\n⚠️  $filesMessage\n');

    final confirm = await prompt.confirm(
      confirmationMessage,
      defaultValue: defaultConfirmation,
    );

    if (!confirm) {
      throw ValidationException.custom(
        'Operation cancelled. Screen files already exist and overwrite was declined.\n'
        'Use --force flag to overwrite existing files without prompting.',
      );
    }

    return true;
  }

  /// Check which files already exist with flexible path handling
  Future<List<String>> _findExistingFiles({
    required String name,
    required String? on,
    required ProjectTemplate template,
    required NameComponent component,
    required Directory targetDir,
    required List<String> checkFiles,
    bool hasSubPath = false,
    String? nameSubPath,
    String? baseName,
    bool createNameSubfolder = true,
  }) async {
    final fileName = StringHelpers.toSnakeCase(name);
    final componentBasePath = ArchitectureCoordinator.getComponentPath(
      component,
      template,
    );

    late String fileDirPath;

    // 🧭 1. إذا كانت لدينا حالة خاصة فيها subPath (مثل: bindings داخل شاشة)
    if (hasSubPath && nameSubPath != null && baseName != null) {
      final baseNameSnake = StringHelpers.toSnakeCase(baseName);
      fileDirPath = on != null && on.isNotEmpty
          ? path.join(componentBasePath, on, baseNameSnake, nameSubPath)
          : path.join(componentBasePath, baseNameSnake, nameSubPath);
    }
    // 🧭 2. إذا كان الأمر يحتوي على on (مثل: gexd make controller Login --on auth)
    else if (on != null && on.isNotEmpty) {
      fileDirPath = createNameSubfolder
          ? path.join(componentBasePath, on, fileName)
          : path.join(componentBasePath, on);
    }
    // 🧭 3. الحالة الافتراضية - بدون on أو subpath
    else {
      fileDirPath = createNameSubfolder
          ? path.join(componentBasePath, fileName)
          : componentBasePath;
    }

    // 🧭 4. نتحقق من الملفات الموجودة
    final existingFiles = <String>[];

    for (final file in checkFiles) {
      final filePath = path.join(fileDirPath, file);
      if (await File(filePath).exists()) {
        final relative = path.relative(filePath, from: targetDir.path);
        existingFiles.add(relative);
      }
    }

    return existingFiles;
  }
}
