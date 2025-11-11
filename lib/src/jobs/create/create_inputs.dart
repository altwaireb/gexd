import 'package:args/args.dart';
import 'package:gexd/gexd.dart';

/// Handles input arguments and prompts for creating a new project
/// Validates inputs and returns a [CreateData] object
/// Throws [ValidationException] if any validation fails
class CreateInputs with HasArgResults, HasName, HasInteractiveMode {
  @override
  final ArgResults argResults;
  final PromptServiceInterface prompt;

  CreateInputs(this.argResults, {required this.prompt});

  /// Handle the input arguments and prompt the user for any missing information.
  /// Validates all inputs and returns a [CreateData] object with the collected data.
  /// Throws [ValidationException] if any validation fails.
  Future<CreateData> handle() async {
    final name = await _getProjectName();
    final template = await _getTemplate();
    final platforms = await _getPlatforms();
    final organization = await _getOrg();
    final description = await _getDescription();
    final full = await _isFullStructure();

    return CreateData(
      name: name,
      template: template,
      platforms: platforms,
      organization: organization,
      description: description,
      full: full,
    );
  }

  // Get project name from positional argument or prompt the user
  // Validate the name to ensure it meets criteria
  // Return the valid project name
  // Throws ValidationException if invalid
  Future<String> _getProjectName() async {
    final nameArg = nameFromArgs;

    if (nameArg != null && nameArg.isNotEmpty) {
      _validateProjectName(nameArg);
      return nameArg;
    }

    return await prompt.input(
      'Project name',
      validator: (value) {
        _validateProjectName(value, toUserMessage: true);
        return null;
      },
    );
  }

  /// Get project template [ProjectTemplate] from --template option
  /// or prompt the user
  Future<ProjectTemplate> _getTemplate() async {
    final templateArg = argResults['template'] as String?;

    // If not in interactive mode and no template specified, use default
    if (!isInteractiveMode && (templateArg == null || templateArg.isEmpty)) {
      return ProjectTemplate.getx;
    }

    if (templateArg != null && templateArg.isNotEmpty) {
      if (ProjectTemplate.isValidKey(templateArg)) {
        return ProjectTemplate.fromKey(templateArg);
      } else {
        throw ValidationException.invalidOption(
          'template',
          templateArg,
          ProjectTemplate.allKeys,
        );
      }
    }

    final options = ProjectTemplate.toList;
    final index = await prompt.select(
      'Select project template',
      options,
      initialIndex: ProjectTemplate.getx.index,
    );
    return ProjectTemplate.values[index];
  }

  /// Get target platforms from --platforms option or prompt the user
  /// Validates the platforms to ensure they are among the allowed options
  /// Returns a list of selected platforms
  Future<List<String>> _getPlatforms() async {
    final arg = argResults["platforms"] as List<String>?;
    final options = ["android", "ios", "web", "macos", "linux", "windows"];
    final defaultPlatforms = ['android', 'ios'];

    // If not in interactive mode and no platforms specified, use defaults
    if (!isInteractiveMode && (arg == null || arg.isEmpty)) {
      return defaultPlatforms;
    }

    if (arg != null && arg.isNotEmpty) {
      final invalid = arg.where((s) => !options.contains(s)).toList();
      if (invalid.isNotEmpty) {
        throw ValidationException.invalidOption(
          'platforms',
          invalid.join(', '),
          options,
        );
      }
      return arg;
    }

    final defaultsBool = options
        .map((opt) => defaultPlatforms.contains(opt))
        .toList();
    final selectedIndices = await prompt.multiSelect(
      'Select supported platforms',
      options,
      defaults: defaultsBool,
    );
    return selectedIndices.map((i) => options[i]).toList();
  }

  Future<String> _getOrg() async {
    final orgArg = argResults["org"] as String?;

    // If not in interactive mode and no org specified, use default
    if (!isInteractiveMode && (orgArg == null || orgArg.isEmpty)) {
      return 'com.example';
    }

    if (orgArg != null && orgArg.isNotEmpty) {
      _validateOrg(orgArg);
      return orgArg;
    }

    return await prompt.input(
      'Organization name',
      defaultValue: 'com.example',
      validator: (value) {
        _validateOrg(value, toUserMessage: true);
        return null;
      },
    );
  }

  Future<String> _getDescription() async {
    final descArg = argResults["description"] as String?;

    // If not in interactive mode and no description specified, use default
    if (!isInteractiveMode && (descArg == null || descArg.isEmpty)) {
      return 'A new Flutter project';
    }

    if (descArg != null && descArg.isNotEmpty) {
      _validateDirectory(descArg);
      return descArg;
    }

    return await prompt.input(
      'Project description',
      defaultValue: 'A new Flutter project',
      validator: (v) {
        _validateDirectory(v, toUserMessage: true);
        return null;
      },
    );
  }

  Future<bool> _isFullStructure() async {
    final fullArg = argResults['full'] as bool?;
    if (fullArg == true) return true;

    // If not in interactive mode and no full flag specified, use default
    if (!isInteractiveMode) return false;

    return await prompt.confirm(
      'Do you want to add all template-specific directories?',
      defaultValue: false,
    );
  }

  // Validate project name with various criteria
  // Throws ValidationException with user-friendly message if invalid
  void _validateProjectName(String value, {bool toUserMessage = false}) {
    final validator = FieldValidator("Project Name", example: "my_project");

    validator.notEmpty(value, toUserMessage);
    validator.minLength(value, 3, toUserMessage);
    validator.maxLength(value, 30, toUserMessage);
    validator.asciiOnly(value, toUserMessage);
    validator.snakeCase(value, 'my_project', toUserMessage);
    validator.startAlpha(value, toUserMessage);
  }

  void _validateOrg(String value, {bool toUserMessage = false}) {
    final validator = FieldValidator("Organization", example: "com.example");

    validator.notEmpty(value, toUserMessage);
    validator.minLength(value, 5, toUserMessage);
    validator.maxLength(value, 50, toUserMessage);
    validator.dotCase(value, 'com.example', toUserMessage);
  }

  void _validateDirectory(String value, {bool toUserMessage = false}) {
    final validator = FieldValidator(
      "Project Directory",
      example: "A new Flutter project",
    );

    validator.notEmpty(value, toUserMessage);
    validator.minLength(value, 3, toUserMessage);
    validator.maxLength(value, 50, toUserMessage);
  }
}
