import 'package:gexd/gexd.dart';

class ModelNotFoundException implements Exception {
  final String message;

  ModelNotFoundException(this.message);

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

    return ModelNotFoundException(message);
  }

  @override
  String toString() => message;
}
