import 'package:gexd/src/core/enums/project_template.dart';

/// Interface for DependencyService
/// Defines methods for adding dependencies
/// to a project based on its template type
abstract class DependencyServiceInterface {
  Future<void> addDependencies({
    required String projectPath,
    required ProjectTemplate template,
  });

  Future<void> pubGet(String projectPath);
}
