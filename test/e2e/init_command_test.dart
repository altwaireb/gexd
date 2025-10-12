@Tags(['e2e'])
library;

import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import '../helpers/e2e_helper.dart';

void main() {
  group('InitCommand E2E Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await E2EHelper.createTemp('gexd_init_e2e_');
    });

    tearDown(() async {
      await E2EHelper.cleanup(tempDir);
    });

    test(
      'should initialize existing Flutter project with GetX template',
      () async {
        // Step 1: Create a basic Flutter project
        final projectName = 'test_getx_init';
        final projectPath = p.join(tempDir.path, projectName);

        final createResult = await Process.run('flutter', [
          'create',
          projectName,
          '--no-pub',
        ], workingDirectory: tempDir.path);

        expect(
          createResult.exitCode,
          equals(0),
          reason: 'Flutter create should succeed',
        );

        // Verify basic Flutter project was created
        expect(Directory(projectPath).existsSync(), isTrue);
        expect(File(p.join(projectPath, 'pubspec.yaml')).existsSync(), isTrue);
        expect(
          File(p.join(projectPath, 'lib', 'main.dart')).existsSync(),
          isTrue,
        );

        // Step 2: Initialize with gexd
        final result = await E2EHelper.runGexd([
          'init',
          '--template',
          'getx',
        ], workingDir: projectPath);

        // Verify init command succeeded
        expect(
          result.exitCode,
          equals(0),
          reason:
              'gexd init should succeed\nstderr: ${result.stderr}\nstdout: ${result.stdout}',
        );

        // Step 3: Verify GetX structure was added
        expect(
          E2EHelper.validateGetXStructure(projectPath),
          isTrue,
          reason: 'Project should have GetX architecture structure after init',
        );

        // Verify GetX dependencies were added
        final pubspecPath = p.join(projectPath, 'pubspec.yaml');
        final pubspecContent = await File(pubspecPath).readAsString();
        expect(
          pubspecContent.contains('get:'),
          isTrue,
          reason: 'pubspec.yaml should contain GetX dependency after init',
        );

        // Verify main.dart was updated
        final mainPath = p.join(projectPath, 'lib', 'main.dart');
        final mainContent = await File(mainPath).readAsString();
        expect(
          mainContent.contains('GetMaterialApp'),
          isTrue,
          reason: 'main.dart should use GetMaterialApp after init',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'should initialize existing Flutter project with Clean Architecture template',
      () async {
        // Step 1: Create a basic Flutter project
        final projectName = 'test_clean_init';
        final projectPath = p.join(tempDir.path, projectName);

        final createResult = await Process.run('flutter', [
          'create',
          projectName,
          '--no-pub',
        ], workingDirectory: tempDir.path);

        expect(
          createResult.exitCode,
          equals(0),
          reason: 'Flutter create should succeed',
        );

        // Step 2: Initialize with gexd clean template
        final result = await E2EHelper.runGexd([
          'init',
          '--template',
          'clean',
          '--full',
        ], workingDir: projectPath);

        // Verify init command succeeded
        expect(
          result.exitCode,
          equals(0),
          reason:
              'gexd init should succeed\nstderr: ${result.stderr}\nstdout: ${result.stdout}',
        );

        // Step 3: Verify Clean Architecture structure was added
        expect(
          E2EHelper.validateCleanStructure(projectPath),
          isTrue,
          reason: 'Project should have Clean Architecture structure after init',
        );

        // Verify dependencies were added
        final pubspecPath = p.join(projectPath, 'pubspec.yaml');
        final pubspecContent = await File(pubspecPath).readAsString();
        expect(
          pubspecContent.contains('get:'),
          isTrue,
          reason: 'pubspec.yaml should contain GetX dependency after init',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test('should handle invalid Flutter projects gracefully', () async {
      // Create empty directory (not a Flutter project)
      final emptyPath = p.join(tempDir.path, 'empty_project');
      await Directory(emptyPath).create();

      final result = await E2EHelper.runGexd([
        'init',
        '--template',
        'getx',
      ], workingDir: emptyPath);

      // Should fail with appropriate error
      expect(
        result.exitCode,
        isNot(0),
        reason: 'gexd init should fail for non-Flutter projects',
      );

      // Should contain validation error message
      final errorOutput = '${result.stderr}${result.stdout}'.toLowerCase();
      expect(
        errorOutput.contains('flutter') || errorOutput.contains('pubspec'),
        isTrue,
        reason: 'Should provide clear error message for non-Flutter project',
      );
    });

    test('should handle invalid templates gracefully in init', () async {
      // Step 1: Create a basic Flutter project
      final projectName = 'test_invalid_template_init';
      final projectPath = p.join(tempDir.path, projectName);

      final createResult = await Process.run('flutter', [
        'create',
        projectName,
        '--no-pub',
      ], workingDirectory: tempDir.path);

      expect(createResult.exitCode, equals(0));

      // Step 2: Try to init with invalid template
      final result = await E2EHelper.runGexd([
        'init',
        '--template',
        'invalid_template',
      ], workingDir: projectPath);

      // Should fail with appropriate error
      expect(
        result.exitCode,
        isNot(0),
        reason: 'gexd init should reject invalid templates',
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
