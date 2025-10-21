import 'package:gexd/src/core/enums/project_template.dart';

abstract class DependencyServiceInterface {
  Future<void> addDependencies({
    required String projectPath,
    required ProjectTemplate template,
  });

  Future<void> pubGet(String projectPath);
}
