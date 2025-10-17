import 'dart:io';
import 'package:meta/meta.dart';
import 'e2e_helpers.dart';
import 'e2e_session.dart';

/// E2ETestBase
///
/// Base class to standardize E2E test behavior across all suites.
/// Handles setup, teardown, and provides helper utilities.
abstract class E2ETestBase {
  late E2ETestSession session;

  @mustCallSuper
  Future<void> setUpAll() async {
    session = await E2ETestSession.create(verbose: true);
  }

  @mustCallSuper
  Future<void> tearDownAll() async {
    await session.cleanup();
  }

  /// Create a project for testing (smart - chooses fake or real automatically)
  Future<TemplateTestProject> createProject(
    String templateKey, {
    Duration? timeout,
    List<String>? platforms,
    bool forInit = false,
  }) async {
    return E2EHelpers.createProject(
      templateKey: templateKey,
      timeout: timeout,
      platforms: platforms,
      forInit: forInit,
    );
  }

  /// Create both GetX and Clean projects for comparison testing (smart mode)
  Future<TemplateTestProjects> createBothProjects({
    Duration? timeout,
    List<String>? platforms,
  }) async {
    return E2EHelpers.createBothProjects(
      timeout: timeout,
      platforms: platforms,
    );
  }

  /// Force creation of real project (for specific test cases)
  Future<TemplateTestProject> createRealProject(
    String templateKey, {
    Duration? timeout,
    List<String>? platforms,
  }) async {
    return E2EHelpers.setupGexdProject(
      templateKey: templateKey,
      timeout: timeout,
      platforms: platforms,
    );
  }

  /// Run a CLI command in a specific directory
  Future<ProcessResult> run(
    List<String> args,
    Directory workingDir, {
    bool verbose = false,
    Duration? timeout,
  }) {
    return E2EHelpers.runCommand(
      args,
      workingDir: workingDir.path,
      verbose: verbose,
      timeout: timeout ?? const Duration(minutes: 3),
    );
  }

  /// Validate project structure
  Future<void> validateStructure(
    String templateKey,
    Directory projectDir,
  ) async {
    return E2EHelpers.validateStructure(
      templateKey: templateKey,
      projectDir: projectDir,
    );
  }

  /// Run pub get in a project
  Future<ProcessResult> runPubGet(Directory projectDir) async {
    return E2EHelpers.runPubGet(projectDir.path);
  }

  /// Check if Flutter is available
  Future<bool> isFlutterAvailable() async {
    return E2EHelpers.isFlutterAvailable();
  }
}
