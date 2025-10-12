/// Post-generation processing service interface
/// run dart format, dart analyze, and tests
abstract class PostGenerationServiceInterface {
  /// Run post-generation operations
  Future<void> runPostGeneration(String projectPath);

  // /// Format code
  // Future<void> formatCode(String projectName);
  // // Run final pub get
  // Future<void> runPubGet(String projectName);

  // /// Validate project
  // Future<void> validateProject(String projectName);

  // /// Run code analysis
  // Future<void> analyzeCode(String projectName);

  // /// Run tests
  // Future<void> runTests(String projectName);
}
