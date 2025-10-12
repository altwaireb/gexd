abstract class FlutterProjectServiceInterface {
  Future<void> createProject({
    required String projectName,
    required String organization,
    required String description,
    required List<String> platforms,
  });
}
