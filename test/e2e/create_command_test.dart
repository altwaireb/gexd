@Tags(['e2e'])
library;

import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import '../helpers/e2e_helpers.dart';

void main() {
  group('CreateCommand E2E Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await E2EHelpers.createTemp();
    });

    tearDown(() async {
      await E2EHelpers.cleanupDir(tempDir);
    });

    test(
      'should create GetX project successfully',
      () async {
        const projectName = 'test_getx_app';
        final projectPath = p.join(tempDir.path, projectName);

        // Run gexd create command with GetX template
        final result = await E2EHelpers.runGexd([
          'create',
          projectName,
          '--template',
          'getx',
          '--org',
          'com.example',
          '--description',
          'A test GetX Flutter app',
          '--platforms',
          'android,ios',
        ], workingDir: tempDir.path);

        // Verify command succeeded
        expect(
          result.exitCode,
          equals(0),
          reason:
              'gexd create should succeed\nstderr: ${result.stderr}\nstdout: ${result.stdout}',
        );

        // Verify project directory was created
        expect(
          Directory(projectPath).existsSync(),
          isTrue,
          reason: 'Project directory should exist at $projectPath',
        );

        // Verify basic Flutter structure
        expect(
          E2EHelpers.validateBasicStructure(projectPath),
          isTrue,
          reason: 'Project should have basic Flutter structure',
        );

        // Verify GetX-specific structure
        expect(
          E2EHelpers.validateGetXStructure(projectPath),
          isTrue,
          reason: 'Project should have GetX architecture structure',
        );

        // Verify pubspec.yaml contains GetX dependency
        final pubspecPath = p.join(projectPath, 'pubspec.yaml');
        final pubspecContent = await File(pubspecPath).readAsString();
        expect(
          pubspecContent.contains('get:'),
          isTrue,
          reason: 'pubspec.yaml should contain GetX dependency',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      'should create Clean Architecture project successfully',
      () async {
        const projectName = 'test_clean_app';
        final projectPath = p.join(tempDir.path, projectName);

        // Run gexd create command with Clean template
        final result = await E2EHelpers.runGexd([
          'create',
          projectName,
          '--template',
          'clean',
          '--org',
          'com.example',
          '--description',
          'A test Clean Architecture Flutter app',
          '--platforms',
          'android,ios',
        ], workingDir: tempDir.path);

        // Verify command succeeded
        expect(
          result.exitCode,
          equals(0),
          reason:
              'gexd create should succeed\nstderr: ${result.stderr}\nstdout: ${result.stdout}',
        );

        // Verify project directory was created
        expect(
          Directory(projectPath).existsSync(),
          isTrue,
          reason: 'Project directory should exist at $projectPath',
        );

        // Verify basic Flutter structure
        expect(
          E2EHelpers.validateBasicStructure(projectPath),
          isTrue,
          reason: 'Project should have basic Flutter structure',
        );

        // Verify Clean Architecture structure
        expect(
          E2EHelpers.validateCleanStructure(projectPath),
          isTrue,
          reason: 'Project should have Clean Architecture structure',
        );

        // Verify pubspec.yaml contains GetX dependency
        final pubspecPath = p.join(projectPath, 'pubspec.yaml');
        final pubspecContent = await File(pubspecPath).readAsString();
        expect(
          pubspecContent.contains('get:'),
          isTrue,
          reason: 'pubspec.yaml should contain GetX dependency',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test('should handle invalid project names gracefully', () async {
      // Test with invalid project name (contains spaces)
      final result = await E2EHelpers.runGexd([
        'create',
        'invalid project name',
        '--template',
        'getx',
        '--org',
        'com.example',
        '--description',
        'Test app',
        '--platforms',
        'android',
      ], workingDir: tempDir.path);

      // Should fail with appropriate error
      expect(
        result.exitCode,
        isNot(0),
        reason: 'gexd should reject invalid project names',
      );

      // Should contain validation error message
      final errorOutput = '${result.stderr}${result.stdout}'.toLowerCase();
      expect(
        errorOutput.contains('invalid') || errorOutput.contains('error'),
        isTrue,
        reason: 'Should provide clear error message for invalid project name',
      );
    });

    test('should handle unsupported template gracefully', () async {
      const projectName = 'test_invalid_template';

      // Test with invalid template
      final result = await E2EHelpers.runGexd([
        'create',
        projectName,
        '--template',
        'invalid_template',
        '--org',
        'com.example',
        '--description',
        'Test app',
        '--platforms',
        'android',
      ], workingDir: tempDir.path);

      // Should fail with appropriate error
      expect(
        result.exitCode,
        isNot(0),
        reason: 'gexd should reject invalid templates',
      );

      // Should contain template error message
      final errorOutput = '${result.stderr}${result.stdout}'.toLowerCase();
      expect(
        errorOutput.contains('template') || errorOutput.contains('invalid'),
        isTrue,
        reason: 'Should provide clear error message for invalid template',
      );
    });
  });
}
