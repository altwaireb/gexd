import 'package:gexd/gexd.dart';

/// Exception thrown when a model file is not found
/// Used to indicate that a specific model file could not be located
/// Provides factory constructors for creating exceptions
/// with detailed messages and suggestions
class ModelNotFoundException implements Exception {
  final String message;
  final String modelName;
  final List<String> searchPaths;

  ModelNotFoundException({
    required this.message,
    required this.modelName,
    this.searchPaths = const [],
  });

  /// Factory constructor to build a descriptive message for missing model files
  factory ModelNotFoundException.fromModelName(
    String modelName,
    ProjectTemplate template,
  ) {
    final suggestion = ArchitectureCoordinator.getComponentPath(
      NameComponent.models,
      template,
    ).replaceFirst(RegExp(r'^/'), '');

    final valueSnake = StringHelpers.toSnakeCase(modelName);
    final suggestionWithFile = '$suggestion/$valueSnake.dart';
    final suggestionWithFileEndModel = '$suggestion/${valueSnake}_model.dart';

    final message =
        '''
❌ Model "$modelName" not found.
🔍 Searched under: $suggestion
💡 Tip: Make sure your model file exists, e.g.:
   • $suggestionWithFile
   • $suggestionWithFileEndModel
''';

    return ModelNotFoundException(
      message: message,
      modelName: modelName,
      searchPaths: [suggestionWithFile, suggestionWithFileEndModel],
    );
  }

  /// Factory constructor with custom search paths
  factory ModelNotFoundException.withSearchPaths(
    String modelName,
    List<String> searchPaths,
  ) {
    final pathsList = searchPaths.map((p) => '   • $p').join('\n');
    final message =
        '''
❌ Model "$modelName" not found.
🔍 Searched paths:
$pathsList
💡 Tip: Make sure your model file exists in one of the above locations.''';

    return ModelNotFoundException(
      message: message,
      modelName: modelName,
      searchPaths: searchPaths,
    );
  }

  /// Get user-friendly message
  String toUserMessage() => message;

  @override
  String toString() => 'ModelNotFoundException: $message';
}
