import 'template_project.dart';

/// TemplateProjects
///
/// Factory class to manage multiple test projects at once.
/// Useful for parameterized testing across different architectures.
class TemplateProjects {
  final TemplateTestProject getxProject;
  final TemplateTestProject cleanProject;

  TemplateProjects({required this.getxProject, required this.cleanProject});

  /// Create both GetX and Clean projects for comparison testing
  static Future<TemplateProjects> createBoth({
    Duration? timeout,
    List<String>? platforms,
  }) async {
    print('🏗️ Setting up both template projects for comparison testing...');

    final getxProject = await TemplateTestProject.create(
      'getx',
      timeout: timeout,
      platforms: platforms,
    );

    final cleanProject = await TemplateTestProject.create(
      'clean',
      timeout: timeout,
      platforms: platforms,
    );

    print('✅ Both template projects setup complete');

    return TemplateProjects(
      getxProject: getxProject,
      cleanProject: cleanProject,
    );
  }

  /// Create multiple projects from a list of template keys
  static Future<List<TemplateTestProject>> createAll(
    List<String> templateKeys,
  ) async {
    return Future.wait(
      templateKeys.map((key) => TemplateTestProject.create(key)),
    );
  }

  /// Cleanup both projects
  Future<void> cleanup() async {
    await Future.wait([getxProject.cleanup(), cleanProject.cleanup()]);
  }
}
