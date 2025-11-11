/// Interface for FlutterProjectService
/// Defines method for creating a Flutter project
/// with specified parameters
/// Implemented by classes that handle Flutter project creation logic
abstract class FlutterProjectServiceInterface {
  Future<void> createProject({
    required String projectName,
    required String organization,
    required String description,
    required List<String> platforms,
  });
}
