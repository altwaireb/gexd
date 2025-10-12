import 'package:gexd/src/services/interfaces/flutter_project_service_interface.dart';

class FlutterProjectServiceMock implements FlutterProjectServiceInterface {
  final List<String> _createdProjects = [];
  bool _shouldSucceed = true;

  /// Configure whether operations should succeed or fail
  void setShouldSucceed(bool succeed) {
    _shouldSucceed = succeed;
  }

  /// Get list of projects that were "created" during testing
  List<String> get createdProjects => List.unmodifiable(_createdProjects);

  /// Clear the list of created projects
  void clearCreatedProjects() {
    _createdProjects.clear();
  }

  @override
  Future<void> createProject({
    required String projectName,
    required String organization,
    required String description,
    required List<String> platforms,
  }) async {
    if (!_shouldSucceed) {
      throw Exception('Mock Flutter project creation failed');
    }

    // Simulate project creation
    await Future.delayed(const Duration(milliseconds: 10));

    _createdProjects.add(projectName);

    print(
      '🧪 Mock: Created Flutter project "$projectName" with org: $organization',
    );
    print('🧪 Mock: Platforms: ${platforms.join(', ')}');
    print('🧪 Mock: Description: $description');
  }

  // Additional helper methods for testing (not part of interface)

  /// Validate project name for testing purposes
  bool isValidProjectName(String name) {
    // Basic validation for testing
    if (name.isEmpty || name.contains(' ') || name.contains('-')) {
      return false;
    }
    return true;
  }

  /// Get available platforms for testing
  List<String> getAvailablePlatforms() {
    return ['android', 'ios', 'web', 'windows', 'macos', 'linux'];
  }

  /// Check if Flutter is "installed" in mock
  bool isFlutterInstalled() {
    return _shouldSucceed;
  }

  /// Get mock Flutter version
  String getFlutterVersion() {
    if (!_shouldSucceed) {
      throw Exception('Flutter not installed');
    }
    return '3.16.0'; // Mock version
  }
}
